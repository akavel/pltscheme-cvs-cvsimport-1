
#define INCLUDE_WITHOUT_PATHS

#ifdef OS_X
  #pragma precompile_target ":MrEdHeadersOSX"
#else
  #ifdef __powerc
    #pragma precompile_target ":MrEdHeadersPPC"
  #else
    #pragma precompile_target ":MrEdHeaders68K" 
  #endif
#endif

#ifdef OS_X

  #define OPAQUE_TOOLBOX_STRUCTS 1
  #define TARGET_API_MAC_CARBON 1

  //#define USE_SENORA_GC 1
  //#define SGC_STD_DEBUGGING 1

  #include <Carbon/Carbon.h>
#else
  #define ACCESSOR_CALLS_ARE_FUNCTIONS 1
  #if 0 // can't use precompiled headers with change to ACCESSOR...
  #ifdef __MWERKS__
  #if defined(__powerc)
   #include <MacHeadersPPC>
  #else
   #include <MacHeaders68K>
  #endif // (__powerc)
  #endif
  #endif // 0
  #include <Events.h>
  #include <Files.h>
#endif

#define WXUNUSED(x)

#define OPERATOR_NEW_ARRAY

/* code added by JBC because compiler no longer handles keyword 
   'far' for PPC */
   
#ifdef __MWERKS__
# if defined(__powerc)
#   define WX_FAR /**/
#  else
#   define WX_FAR far
#  endif
#endif
