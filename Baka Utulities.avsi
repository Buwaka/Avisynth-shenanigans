
function limitring(clip source,float "percentage",int "y",int "u",int "v")
{
y=default(y,3)
u=default(u,2)
v=default(v,2)
percentage=default(percentage,4)
source
dmask=tcanny(1).mt_expand().mt_expand().mt_expand()
dither_convert_8_to_16()
dither_bilateral16(ref=dehalo_alpha_mt(2,2,0.5,1,50,50,2),thr=2,u=u,v=v,y=y)
ditherpost(mode=7)
mt_lutxy(source,mt_merge(source,last,dmask),"x y min x - 0 < x y min x y x min - "+string(percentage)+" / + x y min ?",y=y,u=u,v=v)
repair(last,source,13)
return last
}

function fake16(clip c,String "func",int "mode",int "y",int "u",int "v")
{
mode = default(mode,1)
y=default(y,3)
u=default(u,3)
v=default(v,3)
source = (mode == 2)? dither_get_msb(c) : ditherpost(c,mode=-mode,y=y,u=u,v=v)
source
eval(func)
mask=mt_logic(last,source, "xor",y=y,u=u,v=v).mt_binarize(0,y=y,u=u,v=v)
return mt_merge(c,last.dither_convert_8_to_16(),stackvertical(mask,mask),u=u,v=v,y=y,luma=false)
}

function logic16(clip c1,clip c2,string "mode",int "th1",int "th2",int "y",int "u",int "v")
{
y=default(y,3)
u=default(u,3)
v=default(v,3)
c18= ditherpost(c1,mode=-1)
c28= ditherpost(c2,mode=-1)
mt_logic(c18,c28,mode=mode,th1=th1,th2=th2,y=y,u=u,v=v)
mask=mt_logic(last,c18, "xor",y=y,u=u,v=v).mt_binarize(0,y=y,u=u,v=v)
return mt_merge(c1,c2,stackvertical(mask,mask),y=y,u=u,v=v)

}

function badupscale_aa(clip c,float "dw",float "ss",int "y",int "u",int "v",bool "lsb_inout")\
{
dw=default(dw,2)
ss=default(ss,4)
y=Default(y,2)
u=default(u,3)
v=default(v,3)
lsb_inout=default(lsb_inout,true)
w=width(c)
h=(lsb_inout)? height(c)/2 : height(c)
c
(lsb_inout)? last : Dither_convert_8_to_16()
dither_resize16(w/dw,h/dw,y=y,u=u,v=v)
eedi3_resize(last,width(last)*ss,height(last)/2*ss,lsb_out=true,lsb_in=true,alpha=1,beta=0,gamma=0,nrad=3,mdis=40,y=y,u=u,v=v,lsb=true)
dither_resize16(w,h,y=y,u=u,v=v)
(lsb_inout)? last : ditherpost()
(y < 3)? mergeluma(c) : last
return last
}

function spotmask(clip source,int "expand",int "th1",int "th2",int "clean")
{
th1=default(th1,10)
th2=default(th2,10)
expand=default(expand,3)
clean=default(clean,50)
source
mt_edge("min/max",thy1=th1,thy2=th2,u=2,v=2)
mt_invert(u=2,v=2)
overlay=tmaskcleaner(50)
mt_merge(last,mt_lut(y=0),overlay,u=2,v=2)
return mt_expand_multi(mode="square",sw=expand,sh=expand,u=2,v=2)
}