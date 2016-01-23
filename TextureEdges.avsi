Function TextureEdge(   clip c,float "ss",int "radius", float "wmin",int "subspl",float "thr",float "sigma",int "blur",
\						int "expand",val "mask",bool "static",bool "lsb_inout",int "y",int "u",int "v")
{
ss			= default(ss,1.5)
sigma 		= default(sigma,1.5)
blur 		= default(blur,3)
expand 		= default(expand,1)
mask 		= default(mask,True)
radius  	= default(radius,3)
wmin    	= default(wmin,0)
subspl  	= default(subspl,1)
thr     	= default(thr,1)
y 			= default(y,3) 
u  			= default(u,2)
v 			= default(v,2)
static  	= default(static, True)
lsb_inout   = default(lsb_inout,False)
w 			= width(c)
h 			= (lsb_inout) ? height(c)/2 : height(c)

grainclip 	  = blankclip(c,color_yuv=$808080,width=m4(w*ss),height=m4(h*ss)).addgrainc(100,constant=static).mt_lut("x 32 %").to16()
maskclip 	  = isclip(mask) ? mask : tcanny(((lsb_inout)? ditherpost(c) : c),sigma=sigma).mt_expand_rec(expand).ablur(blur,1)
mask		  = isclip(mask) ? true : mask
ssclip 		  = (ss != 1) ? (lsb_inout) ? dither_resize16(c,m4(w*ss),m4(h*ss),y=y,u=u,v=v) : spline36resize(c,m4(w*ss),m4(h*ss)).to16() : c
texture 	  = dither_bilateral16(ssclip, grainclip, radius, wmin=wmin, subspl=subspl,thr=thr,y=y,u=u,v=v)
sized 		  = (ss != 1) ? (lsb_inout) ? dither_resize16(texture,w,h,y=y,u=u,v=v) : ditherpost(texture).spline36resize(w,h) : texture
merged 		  = (!mask) ? sized : (lsb_inout) ?  dither_merge16_8(c,sized,maskclip,luma=true,y=y,u=u,v=v) : mt_merge(c,sized,maskclip,luma=true,y=y,u=u,v=v)


return sized
}




function mt_inpand_rec(clip c, int radius) 
{
	return radius <= 1 ? c.mt_inpand() : mt_inpand_rec(c.mt_inpand(), radius - 1)
}

function mt_expand_rec(clip c, int radius) 
{
	return radius <= 1 ? c.mt_expand() : mt_expand_rec(c.mt_expand(), radius - 1)
}

function to16(clip c)
{
dither_convert_8_to_16(c)
}