/* 
   Provides:
      Mach-based allocator (uses alloc_cache.c)
      macosx_init_exception_handler() --- installs fault handler
      size_type -- the type of the heap size
      determine_max_heap_size()
   Requires:
      TEST = 0
      GENERATIONS --- zero or non-zero
      designate_modified --- when GENERATIONS is non-zero
      my_qsort (for alloc_cache.c)
      LOGICALLY_ALLOCATING_PAGES(len)
      ACTUALLY_ALLOCATING_PAGES(len)
      LOGICALLY_FREEING_PAGES(len)
      ACTUALLY_FREEING_PAGES(len)
   Optional:
      CHECK_USED_AGAINST_MAX(len)
      GCPRINT
      GCOUTF
      DONT_NEED_MAX_HEAP_SIZE --- to disable a provide
*/

#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>
#include <mach/mach.h>
#include <mach/mach_error.h>
#include <architecture/ppc/cframe.h>

#ifndef TEST
# define TEST 1
# include "my_qsort.c"
void designate_modified(void *p);
#endif

#ifndef GCPRINT
# define GCPRINT fprintf
# define GCOUTF stderr
#endif
#ifndef CHECK_USED_AGAINST_MAX
# define CHECK_USED_AGAINST_MAX(x) /* empty */
#endif

/* Forward declaration: */
inline static void *find_cached_pages(size_t len, size_t alignment);

/* the structure of an exception msg and its reply */
typedef struct rep_msg {
  mach_msg_header_t head;
  NDR_record_t NDR;
  kern_return_t ret_code;
} mach_reply_msg_t;

typedef struct exc_msg {
  mach_msg_header_t head;
  /* start of the kernel processed data */
  mach_msg_body_t msgh_body;
  mach_msg_port_descriptor_t thread;
  mach_msg_port_descriptor_t task;
  /* end of the kernel processed data */
  NDR_record_t NDR;
  exception_type_t exception;
  mach_msg_type_number_t code_cnt;
  exception_data_t code;
  /* some padding */
  char pad[512];
} mach_exc_msg_t;

/* this is a neat little mach callback */
extern boolean_t exc_server(mach_msg_header_t *in, mach_msg_header_t *out);

/* these are the globals everyone needs */
#define page_size vm_page_size
static mach_port_t task_self = NULL;
static mach_port_t exc_port = NULL;

/* the VM subsystem as defined by the GC files */
static void *malloc_pages(size_t len, size_t alignment)
{
  kern_return_t retval;
  size_t extra = 0;
  void *r;

  if(!task_self) task_self = mach_task_self();

  CHECK_USED_AGAINST_MAX(len);
  
  /* round up to the nearest page: */
  if(len & (page_size - 1))
    len += page_size - (len & (page_size - 1));

  r = find_cached_pages(len, alignment);
  if (r)
    return r;

  extra = alignment;

  retval = vm_allocate(task_self, (vm_address_t*)&r, len + extra, TRUE);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "Couldn't allocate memory: %s\n", mach_error_string(retval));
    abort();
  }

  if(extra) {
    /* we allocated too large so we can choose the alignment */
    void *real_r;
    long pre_extra;

    real_r = (void*)(((unsigned long)r + (alignment-1)) & (~(alignment-1)));
    pre_extra = real_r - r;
    if(pre_extra) {
      retval = vm_deallocate(task_self, (vm_address_t)r, pre_extra);
      if(retval != KERN_SUCCESS) {
	GCPRINT(GCOUTF, "WARNING: couldn't deallocate pre-extra: %s\n",
	       mach_error_string(retval));
      }
    }
    if(pre_extra < extra) {
      retval = vm_deallocate(task_self, (vm_address_t)real_r + len, 
			     extra - pre_extra);
      if(retval != KERN_SUCCESS) {
	GCPRINT(GCOUTF, "WARNING: couldn't deallocate post-extra: %s\n",
	       mach_error_string(retval));
      }
    }
    r = real_r;
  }

  ACTUALLY_ALLOCATING_PAGES(len);
  LOGICALLY_ALLOCATING_PAGES(len);

  return r;
}

static void system_free_pages(void *p, size_t len)
{
  kern_return_t retval;

  retval = vm_deallocate(task_self, (vm_address_t)p, len);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "WARNING: couldn't deallocate page %p: %s\n", p,
	   mach_error_string(retval));
  }
}

static void protect_pages(void *p, size_t len, int writeable)
{
  kern_return_t retval;

  if(len & (page_size - 1)) {
    len += page_size - (len & (page_size - 1));
  }

  retval = vm_protect(task_self, (vm_address_t)p, len, FALSE,
		      writeable ? VM_PROT_ALL 
		      : (VM_PROT_READ | VM_PROT_EXECUTE));
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "WARNING: couldn't protect %li bytes of page %p%s\n",
	   len, p, mach_error_string(retval));
  }
}

#include "alloc_cache.c"

#ifndef DONT_NEED_MAX_HEAP_SIZE
typedef int64_t size_type;

static unsigned long determine_max_heap_size()
{
  struct rlimit *rlim = malloc(sizeof(struct rlimit));
  size_type retval = 0;

  getrlimit(RLIMIT_RSS, rlim);
  retval = rlim->rlim_cur; free(rlim);
  return (retval == RLIM_INFINITY) ? (1024 * 1024 * 1024) : retval;
}
#endif

/* these are some less neat mach callbacks */
kern_return_t catch_exception_raise_state(mach_port_t port,
					  exception_type_t exception_type,
					  exception_data_t exception_data,
					  mach_msg_type_number_t data_cnt,
					  thread_state_flavor_t *flavor,
					  thread_state_t in_state,
					  mach_msg_type_number_t is_cnt,
					  thread_state_t out_state,
					  mach_msg_type_number_t os_cnt)
{
  return KERN_FAILURE;
}

kern_return_t catch_exception_raise_state_identitity
  (mach_port_t port,  mach_port_t thread_port, mach_port_t task_port,
   exception_type_t exception_type, exception_data_t exception_data,
   mach_msg_type_number_t data_count, thread_state_flavor_t *state_flavor,
   thread_state_t in_state, mach_msg_type_number_t in_state_count,
   thread_state_t out_state, mach_msg_type_number_t out_state_count)
{
  return KERN_FAILURE;
}

kern_return_t catch_exception_raise(mach_port_t port,
				    mach_port_t thread_port,
				    mach_port_t task_port,
				    exception_type_t exception_type,
				    exception_data_t exception_data,
				    mach_msg_type_number_t data_count)
{
#if  GENERATIONS
  /* kernel return value is in exception_data[0], faulting address in
     exception_data[1] */
  if(exception_data[0] == KERN_PROTECTION_FAILURE) {
    designate_modified((void*)exception_data[1]);
    return KERN_SUCCESS;
  } else 
#endif
    return KERN_FAILURE;
}

/* this is the thread which forwards of exceptions read from the exception
   server off to our exception catchers and then back out to the other
   thread */
void exception_thread(void)
{
  mach_msg_header_t *message;
  mach_msg_header_t *reply;
  kern_return_t retval;
  
  /* allocate the space for the message and reply */
  message = (mach_msg_header_t*)malloc(sizeof(mach_exc_msg_t));
  reply = (mach_msg_header_t*)malloc(sizeof(mach_reply_msg_t));
  /* do this loop forever */
  while(1) {
    /* block until we get an exception message */
    retval = mach_msg(message, MACH_RCV_MSG, 0, sizeof(mach_exc_msg_t), 
		      exc_port, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
    /* forward off the handling of this message */
    if(!exc_server(message, reply)) {
      GCPRINT(GCOUTF, "INTERNAL ERROR: exc_server() didn't like something\n");
      abort();
    }
    /* send the message back out to the thread */
    retval = mach_msg(reply, MACH_SEND_MSG, sizeof(mach_reply_msg_t), 0, 
		      MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
  }
}

/* this initializes the subsystem (sets the exception port, starts the
   exception handling thread, etc) */
static void macosx_init_exception_handler() 
{
  mach_port_t thread_self, exc_port_s, exc_thread;
  ppc_thread_state_t *exc_thread_state;
  mach_msg_type_name_t type;
  void *subthread_stack;
  kern_return_t retval;

  /* get ids for ourself */
  if(!task_self) task_self = mach_task_self();
  thread_self = mach_thread_self();

  /* allocate the port we're going to get exceptions on */
  retval = mach_port_allocate(task_self, MACH_PORT_RIGHT_RECEIVE, &exc_port);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "Couldn't allocate exception port: %s\n", 
	   mach_error_string(retval));
    abort();
  }

  /* extract out the send rights for that port, which the OS needs */
  retval = mach_port_extract_right(task_self, exc_port, MACH_MSG_TYPE_MAKE_SEND,
				   &exc_port_s, &type);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "Couldn't extract send rights: %s\n", mach_error_string(retval));
    abort();
  }

  /* set the exception ports for this thread to the above */
  retval = thread_set_exception_ports(thread_self, EXC_MASK_BAD_ACCESS, 
				      exc_port_s, EXCEPTION_DEFAULT, 
				      PPC_THREAD_STATE);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "Couldn't set exception ports: %s\n", mach_error_string(retval));
    abort();
  }

  /* set up the subthread */
  retval = thread_create(task_self, &exc_thread);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "Couldn't create exception thread: %s\n", mach_error_string(retval));
    abort();
  }
  subthread_stack = (void*)malloc(page_size);
  subthread_stack += (page_size - C_ARGSAVE_LEN - C_RED_ZONE);
  exc_thread_state = (ppc_thread_state_t*)malloc(sizeof(ppc_thread_state_t));
  exc_thread_state->srr0 = (unsigned int)exception_thread;
  exc_thread_state->r1 = (unsigned int)subthread_stack;
  retval = thread_set_state(exc_thread, PPC_THREAD_STATE,
			    (thread_state_t)exc_thread_state,
			    PPC_THREAD_STATE_COUNT);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "Couldn't set subthread state: %s\n", mach_error_string(retval));
    abort();
  }
  retval = thread_resume(exc_thread);
  if(retval != KERN_SUCCESS) {
    GCPRINT(GCOUTF, "Couldn't resume subthread: %s\n", mach_error_string(retval));
    abort();
  }
}

#if TEST
#define MPAGE_SIZE 16384
#define BPAGE_SIZE 20034

char *normal_page = NULL;
char *big_page = NULL;

void designate_modified(void *p)
{
  if((p >= normal_page) && (p < (normal_page + MPAGE_SIZE))) {
    protect_pages(p, MPAGE_SIZE, 1);
    return;
  }
  if((p >= big_page) && (p < (big_page + BPAGE_SIZE))) {
    protect_pages(p, BPAGE_SIZE, 1);
    return;
  }
  printf("Unrecognized write: %p\n", p);
  abort();
}

int main(int argc, char **argv)
{
  macosx_init_exception_handler();
  printf("Allocating test pages:\n");
  normal_page = malloc_pages(MPAGE_SIZE, MPAGE_SIZE);
  printf("  ... normal page at %p\n", normal_page);
  big_page = malloc_pages(BPAGE_SIZE, MPAGE_SIZE);
  printf("  ... big page at %p\n", big_page);
  printf("Setting protection on test pages\n");
  protect_pages(normal_page, MPAGE_SIZE, 0);
  printf("  ... normal page %p set\n", normal_page);
  protect_pages(big_page, MPAGE_SIZE, 0);
  printf("  ... big page %p set\n", big_page);
  printf("Writing to test pages\n");
  normal_page[2] = 'A';
  big_page[2] = 'A';
  printf("Reading from test pages:\n");
  printf("  ... normal_page %p's second byte is %c\n", normal_page, normal_page[2]);
  printf("  ... big_page %p's second byte is %c\n", big_page, big_page[2]);
  printf("Freeing test pages:\n");
  free_pages(normal_page, MPAGE_SIZE);
  printf("  ... freed normal page\n");
  free_pages(big_page, MPAGE_SIZE);
  printf("  ... freed big page\n");
}
#endif
