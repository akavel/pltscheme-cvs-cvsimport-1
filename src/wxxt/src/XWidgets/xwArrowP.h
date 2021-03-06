/* Generated by wbuild
 * (generator version 3.2)
 */
#ifndef ___XWARROWP_H
#define ___XWARROWP_H
#include <./xwBoardP.h>
#include <./xwArrow.h>
_XFUNCPROTOBEGIN
typedef void  (*draw_arrow_Proc)(
#if NeedFunctionPrototypes
Widget,int 
#endif
);
#define XtInherit_draw_arrow ((draw_arrow_Proc) _XtInherit)

typedef struct {
/* methods */
draw_arrow_Proc draw_arrow;
/* class variables */
} XfwfArrowClassPart;

typedef struct _XfwfArrowClassRec {
CoreClassPart core_class;
CompositeClassPart composite_class;
XfwfCommonClassPart xfwfCommon_class;
XfwfFrameClassPart xfwfFrame_class;
XfwfBoardClassPart xfwfBoard_class;
XfwfArrowClassPart xfwfArrow_class;
} XfwfArrowClassRec;

typedef struct {
/* resources */
Alignment  direction;
Pixel  foreground;
Dimension  arrowShadow;
Boolean  repeat;
Cardinal  initialDelay;
Cardinal  repeatDelay;
XtCallbackList  callback;
Boolean  drawgrayArrow;
/* private state */
GC  arrowgc;
GC  arrowlightgc;
GC  arrowdarkgc;
long  timer;
XPoint  p1[3];
XPoint  p2[4];
XPoint  p3[4];
XPoint  p4[4];
Dimension  a2;
Dimension  a3;
} XfwfArrowPart;

typedef struct _XfwfArrowRec {
CorePart core;
CompositePart composite;
XfwfCommonPart xfwfCommon;
XfwfFramePart xfwfFrame;
XfwfBoardPart xfwfBoard;
XfwfArrowPart xfwfArrow;
} XfwfArrowRec;

externalref XfwfArrowClassRec xfwfArrowClassRec;

_XFUNCPROTOEND
#endif /* ___XWARROWP_H */
