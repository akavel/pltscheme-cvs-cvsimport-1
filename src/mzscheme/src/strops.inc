
/**********************************************************************/
/*                           constructors                             */
/**********************************************************************/

Scheme_Object *
X(scheme_make_sized_offset, _string)(Xchar *chars, long d, long len, int copy)
{
  Scheme_Object *str;

  if (!chars) chars = EMPTY;

  str = scheme_alloc_object();
  str->type = scheme_x_string_type;

  if (len < 0)
    len = xstrlen(chars XFORM_OK_PLUS d);
  if (copy) {
    Xchar *naya;

    naya = (Xchar *)scheme_malloc_fail_ok(scheme_malloc_atomic, (len + 1) * sizeof(Xchar));
    SCHEME_X_STR_VAL(str) = naya;
    memcpy(naya, chars + d, len * sizeof(Xchar));
    naya[len] = 0;
  } else
    SCHEME_X_STR_VAL(str) = chars + d;
  SCHEME_X_STRTAG_VAL(str) = len;

  return str;
}

Scheme_Object *
X(scheme_make_sized, _string)(Xchar *chars, long len, int copy)
{
  return X(scheme_make_sized_offset, _string)(chars, 0, len, copy);
}

Scheme_Object *
X(scheme_make_immutable_sized, _string)(Xchar *chars, long len, int copy)
{
  Scheme_Object *s;
  
  s = X(scheme_make_sized_offset, _string)(chars, 0, len, copy);
  SCHEME_SET_X_STRING_IMMUTABLE(s);

  return s;
}

Scheme_Object *
X(scheme_make, _string_without_copying)(Xchar *chars)
{
  return X(scheme_make_sized_offset, _string)(chars, 0, -1, 0);
}

Scheme_Object *
X(scheme_make, _string)(const Xchar *chars)
{
  return X(scheme_make_sized_offset, _string)((Xchar *)chars, 0, -1, 1);
}

Scheme_Object *
X(scheme_alloc, _string)(int size, Xchar fill)
{
  Scheme_Object *str;
  Xchar *s;
  int i;
  
  if (size < 0) {
    str = scheme_make_integer(size);
    scheme_wrong_type("make-" XSTRINGSTR, "non-negative exact integer",
		      -1, 0, &str);
  }

  str = scheme_alloc_object();
  str->type = scheme_x_string_type;
  s = (Xchar *)scheme_malloc_fail_ok(scheme_malloc_atomic, sizeof(Xchar)*(size + 1));
  for (i = size; i--; ) {
    s[i] = fill;
  }
  s[size] = 0;
  SCHEME_X_STR_VAL(str) = s;
  SCHEME_X_STRTAG_VAL(str) = size;

  return str;
}

/**********************************************************************/
/*                          string procs                              */
/**********************************************************************/

static Scheme_Object *
X__(string_p) (int argc, Scheme_Object *argv[])
{
  return (SCHEME_X_STRINGP(argv[0]) ? scheme_true : scheme_false);
}

static Scheme_Object *
X_(make, string) (int argc, Scheme_Object *argv[])
{
  long len;
  Xchar fill;
  Scheme_Object *str;

  len = scheme_extract_index("make-" XSTRINGSTR, 0, argc, argv, -1, 0);

  if (len == -1) {
    scheme_raise_out_of_memory("make-" XSTRINGSTR, "making " XSTR "string of length %s",
			       scheme_make_provided_string(argv[0], 0, NULL));
  }

  if (argc == 2) {
    if (!CHARP(argv[1]))
      scheme_wrong_type("make-" XSTRINGSTR, CHAR_STR, 1, argc, argv);
    fill = CHAR_VAL(argv[1]);
  } else
    fill = 0;

  str = X(scheme_alloc, _string)(len, fill);
  return str;
}

static Scheme_Object *
X__(string) (int argc, Scheme_Object *argv[])
{
  Scheme_Object *str;
  int i;

  str = X(scheme_alloc, _string)(argc, 0);

  for ( i=0 ; i<argc ; ++i ) {
    if (!CHARP(argv[i]))
      scheme_wrong_type(XSTRINGSTR, CHAR_STR, i, argc, argv);
    SCHEME_X_STR_VAL(str)[i] = CHAR_VAL(argv[i]);
  }

  return str;
}

static Scheme_Object *
X__(string_length) (int argc, Scheme_Object *argv[])
{
  if (!SCHEME_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "-length", XSTR "string", 0, argc, argv);

  return scheme_make_integer(SCHEME_X_STRTAG_VAL(argv[0]));
}

static Scheme_Object *
X__(string_ref) (int argc, Scheme_Object *argv[])
{
  long i, len;
  int c;
  Xchar *str;

  if (!SCHEME_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "-ref", XSTR "string", 0, argc, argv);

  str = SCHEME_X_STR_VAL(argv[0]);
  len = SCHEME_X_STRTAG_VAL(argv[0]);

  i = scheme_extract_index(XSTRINGSTR "-ref", 1, argc, argv, len, 0);

  if (i >= len) {
    scheme_out_of_string_range(XSTRINGSTR "-ref", "", argv[1], argv[0], 0, len - 1);
    return NULL;
  }

  c = ((uXchar *)str)[i];
  return MAKE_CHAR(c);
}

static Scheme_Object *
X__(string_set) (int argc, Scheme_Object *argv[])
{
  long i, len;
  Xchar *str;
  
  if (!SCHEME_MUTABLE_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "-set!", "mutable " XSTR "string", 0, argc, argv);

  str = SCHEME_X_STR_VAL(argv[0]);
  len = SCHEME_X_STRTAG_VAL(argv[0]);

  i = scheme_extract_index(XSTRINGSTR "-set!", 1, argc, argv, len, 0);

  if (!CHARP(argv[2]))
    scheme_wrong_type(XSTRINGSTR "-set!", CHAR_STR, 2, argc, argv);

  if (i >= len) {
    scheme_out_of_string_range(XSTRINGSTR "-set!", "", argv[1], argv[0], 0, len - 1);
    return NULL;
  }

  str[i] = CHAR_VAL(argv[2]);

  return scheme_void;
}

static Scheme_Object *
X__(substring) (int argc, Scheme_Object *argv[])
{
  long start, finish;
  Xchar *chars;
  Scheme_Object *str;

  if (!SCHEME_X_STRINGP(argv[0]))
    scheme_wrong_type(SUBXSTR, XSTR "string", 0, argc, argv);

  chars = SCHEME_X_STR_VAL(argv[0]);

  scheme_get_substring_indices(SUBXSTR, argv[0], argc, argv, 1, 2,
			       &start, &finish);

  str = X(scheme_alloc, _string)(finish-start, 0);
  memcpy(SCHEME_X_STR_VAL(str), chars + start, (finish - start) * sizeof(Xchar));
  
  return str;
}

static Scheme_Object *
X__(string_append) (int argc, Scheme_Object *argv[])
{
  Scheme_Object *naya, *s;
  Xchar *chars;
  int i;
  long len;

  len = 0;
  for (i = 0; i < argc; i++) {
    s = argv[i];
    if (!SCHEME_X_STRINGP(s))
      scheme_wrong_type(XSTRINGSTR "-append", "string", i, argc, argv);
    len += SCHEME_X_STRTAG_VAL(s);
  }

  if (!len)
    return X(zero_length, _string);

  naya = X(scheme_alloc, _string)(len, 0);
  chars = SCHEME_X_STR_VAL(naya);

  for (i = 0; i < argc; i++) {
    s = argv[i];
    len = SCHEME_X_STRTAG_VAL(s);
    memcpy(chars, SCHEME_X_STR_VAL(s), len * sizeof(Xchar));
    chars = chars XFORM_OK_PLUS len;
  }
  
  return naya;
}

Scheme_Object *
X(scheme_append, _string)(Scheme_Object *str1, Scheme_Object *str2)
{
  int len1, len2;
  Xchar *r;
  Scheme_Object *naya;

  len1 = SCHEME_X_STRTAG_VAL(str1);
  len2 = SCHEME_X_STRTAG_VAL(str2);

  naya = X(scheme_alloc, _string)(len1 + len2, 0);

  r = SCHEME_X_STR_VAL(naya);
  memcpy(r, SCHEME_X_STR_VAL(str1), len1 * sizeof(Xchar));
  memcpy(r + len1, SCHEME_X_STR_VAL(str2), len2 * sizeof(Xchar));

  r[len1 + len2] = 0;

  return naya;
}

static Scheme_Object *
X__(string_to_list) (int argc, Scheme_Object *argv[])
{
  int len, i;
  uXchar *chars;
  Scheme_Object *pair = scheme_null, *v;

  if (!SCHEME_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "->list", XSTR "string", 0, argc, argv);

  chars = SCHEME_X_STR_VAL(argv[0]);
  len = SCHEME_X_STRTAG_VAL(argv[0]);

  if (len < 0xFFF) {
    for (i = len ; i--; ) {
      v = MAKE_CHAR(chars[i]);
      pair = scheme_make_pair(v, pair);
    }
  } else {
    for (i = len ; i--; ) {
      if (!(i & 0xFFF))
	SCHEME_USE_FUEL(0xFFF);
      v = MAKE_CHAR(chars[i]);
      pair = scheme_make_pair(v, pair);
    }
  }

  return pair;
}

static Scheme_Object *
X_(list_to, string) (int argc, Scheme_Object *argv[])
{
  int len, i;
  Scheme_Object *list, *str, *ch;

  list = argv[0];
  len = scheme_list_length(list);
  str = X(scheme_alloc, _string)(len, 0);
  i = 0;
  while (SCHEME_PAIRP (list)) {
    ch = SCHEME_CAR(list);
    
    if (!CHARP(ch))
      scheme_wrong_type("list->" XSTRINGSTR, "list of " CHAR_STR, 0, 
			argc, argv);
    
    SCHEME_X_STR_VAL(str)[i] = CHAR_VAL(ch);
    i++;
    list = SCHEME_CDR(list);
  }  
  
  if (!SCHEME_NULLP(list))
    scheme_wrong_type("list->" XSTRINGSTR, "list of" CHAR_STR, 0, argc, argv);

  return str;
}

static Scheme_Object *
X__(string_copy) (int argc, Scheme_Object *argv[])
{
  if (!SCHEME_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "-copy", XSTR "string", 0, argc, argv);

  return X(scheme_make_sized, _string)(SCHEME_X_STR_VAL(argv[0]), 
					   SCHEME_X_STRTAG_VAL(argv[0]), 1);
}

static Scheme_Object *
X__(string_copy_bang)(int argc, Scheme_Object *argv[])
{
  long istart, ifinish;
  long ostart, ofinish;

  if (!SCHEME_MUTABLE_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "-copy!", "mutable " XSTR "string", 0, argc, argv);

  scheme_get_substring_indices(XSTRINGSTR "-copy!", argv[0], 
			       argc, argv, 1, 5, 
			       &ostart, &ofinish);

  if (!SCHEME_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "-copy!", XSTR "string", 2, argc, argv);

  scheme_get_substring_indices(XSTRINGSTR "-copy!", argv[2], 
			       argc, argv, 3, 4, 
			       &istart, &ifinish);

  if ((ofinish - ostart) < (ifinish - istart)) {
    scheme_arg_mismatch(XSTRINGSTR "-copy!",
			"not enough room in target " XSTR "string: ",
			argv[2]);
    return NULL;
  }

  memmove(SCHEME_X_STR_VAL(argv[0]) + ostart,
	  SCHEME_X_STR_VAL(argv[2]) + istart,
	  (ifinish - istart) * sizeof(Xchar));
  
  return scheme_void;
}

static Scheme_Object *
X__(string_fill) (int argc, Scheme_Object *argv[])
{
  int len, i;
  Xchar *chars, ch;

  if (!SCHEME_MUTABLE_X_STRINGP(argv[0]))
    scheme_wrong_type(XSTRINGSTR "-fill!", "mutable " XSTR "string", 0, argc, argv);
  if (!CHARP(argv[1]))
    scheme_wrong_type(XSTRINGSTR "-fill!", CHAR_STR, 1, argc, argv);
  
  chars = SCHEME_X_STR_VAL(argv[0]);
  ch = CHAR_VAL(argv[1]);
  len = SCHEME_X_STRTAG_VAL(argv[0]);
  for (i = 0; i < len; i++) {
    chars[i] = ch;
  }

  return scheme_void;
}

static Scheme_Object *
X__(string_to_immutable) (int argc, Scheme_Object *argv[])
{
  Scheme_Object *s = argv[0];

  if (!SCHEME_X_STRINGP(s))
    scheme_wrong_type(XSTRINGSTR "->immutable-" XSTRINGSTR, XSTR "string", 0, argc, argv);

  if (SCHEME_MUTABLE_X_STRINGP(s)) {
    Scheme_Object *s2;
    s2 = X(scheme_make_sized, _string)(SCHEME_X_STR_VAL(s), SCHEME_X_STRTAG_VAL(s), 1);
    SCHEME_SET_X_STRING_IMMUTABLE(s2);
    return s2;
  } else
    return s;
}

static Scheme_Object *
X_(append_all, strings_backwards)(Scheme_Object *l)
{
  int i, len;
  Scheme_Object **a;

  len = scheme_list_length(l);
  a = MALLOC_N(Scheme_Object *, len);
  for (i = len; i--; l = SCHEME_CDR(l)) {
    a[i] = SCHEME_CAR(l);
  }
  
  return X__(string_append)(len, a);
}

#undef SCHEME_X_STR_VAL
#undef SCHEME_X_STRTAG_VAL
#undef SCHEME_X_STRINGP
#undef SCHEME_MUTABLE_X_STRINGP
#undef SCHEME_SET_X_STRING_IMMUTABLE
#undef scheme_x_string_type
#undef X
#undef X_
#undef X__
#undef EMPTY
#undef Xchar
#undef uXchar
#undef XSTR
#undef XSTRINGSTR
#undef SUBXSTR
#undef CHARP
#undef CHAR_VAL
#undef CHAR_STR
#undef MAKE_CHAR
#undef xstrlen