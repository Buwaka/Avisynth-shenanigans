function ediaa(clip c,int "mode",bool "lsb_inout",int "mask",int "mthr",int "y",int "u",int "v"){
	mode = default(mode, 1)
	mthr=default(mthr,60)
	mask=default(mask,1)
	y=default(y,3)
	u=default(u,2)
	v=default(v,2)
	yb=(y==3)? true : false
	ub=(u==3)? true : false
	vb=(v==3)? true : false
	chroma=(u == 3 || v == 3)? true : false
	a= (lsb_inout)? ditherpost(c,mode=-1) : c
	sh=height(a)
	aa = (mode == 1)? a.nnEDI3(field=1,dh=true,y=yb,u=ub,v=vb).fTurnRight(chroma).nnEDI3(field=1,dh=true,y=yb,u=ub,v=vb).fTurnLeft(chroma).spline36resize(a.width,a.height,-0.5,-0.5,2*a.width+.001,2*a.height+.001) : a.EEDI3(field=1,dh=true,y=yb,u=ub,v=vb).fTurnRight(chroma).EEDI3(field=1,dh=true,y=yb,u=ub,v=vb).fTurnLeft(chroma).spline36resize(a.width,a.height,-0.5,-0.5,2*a.width+.001,2*a.height+.001)
	if(mask == 1) {
mclip = a.mt_edge("prewitt", mthr, mthr, mthr/2, mthr/2, y, u, v).RemoveGrain(17)
\ .mt_expand(y=y, u=u, v=v).mt_inflate(y=y, u=u, v=v)
}
else if (mask == 2) {
mclip = a.mt_edge("prewitt", 0, 255, 0, 255, y=3, u=3, v=3).LuMergePlanes("max",1.5,1.5)
\ .mt_binarize(mthr).RemoveGrain(17,-1).mt_expand().mt_inflate()
}
else if (mask == 3) {
mclip = a.mt_edge("hprewitt", 0, 255, 0, 255, y=3, u=3, v=3).LuMergePlanes("max",1.5,1.5,2).mt_expand().mt_inpand()
\ .tmaskcleaner(sh/36,30).mt_binarize(mthr).mt_inflate()
}
else if (mask == 4) {
# mask by tophf
lines = a.ConvertToY8().mt_lutxy(a.binomialblur(3,u=1,v=1), "x " + String(mthr/7) + " + y < y x - 64 * 0 ?")
lexp = lines.mt_expand_multi(sw=3,sh=3).mt_inpand_multi(sw=4,sh=4)
mclip = lexp.removegrain(17,-1).mt_lutxy(lines,"y x -").mt_expand.tmaskcleaner(sh/16)
}
    dither_merge16_8(c,aa.dither_convert_8_to_16(),mclip,luma=((mask==1)? false : true),y=y,u=u,v=v)
	return last
}
 