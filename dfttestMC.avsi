# Motion-compensated dfttest by twc
# Aka: Really Really Really Slow
#
# v2 by BakaProxy
# Aka: Even more Really Really Really slow
# Added: Recalculate, (proper) 16 bit input handling, dither_luma_rebuild and some masking to prevent 16 bit data loss from 8 bit Mdegrain and Mcompensate
#
#
# Requirements:
# dfttest
# MVTools2
# 
# Suggested:
# Dither (for stack16 processing)
#
# Description of function parameters:
#
# pp = Clip to calculate vectors from (default input)
# mc = Number of frames in each direction to compensate (default 2, max 5)
# mdg = Run MDeGrain before dfttest (default false)
# mdgSAD = thSAD for MDeGrain (default undefined)
# lsb = stack16 output and processing (default false)
#
# dfttest Y, U, V, sigma, sbsize, sosize, tbsize, and dither are supported.
# Extra dfttest parameters may be passed via dfttest_params.
# MVTools2 pel, thSCD, thSAD, blksize, overlap, dct, search, and 
# searchparam are also supported. 
#
# sigma is the main control of dfttest strength.
# tbsize should not be set higher than mc * 2 + 1.

function dfttestMC(clip input, clip "pp", int "mc", bool "mdg", bool "Y", bool "U", bool "V", float "sigma", int "sbsize", int "sosize", int "tbsize", int "dither", bool "lsb",bool "lsb_in",bool "pp_lsb_in",int "super_filter",
	\ string "dfttest_params",float "rStr",float "Amp", int "mdgSAD", int "thSAD", int "thSCD1", int "thSCD2", bool "recalculate", bool "truemotion", int "pel", int "blksize", int "search", int "searchparam", int "overlap",
		\ int "dct")
{
	# Set default options. Most external parameters are passed valueless.
	
	mc = default(mc, 2).min(5)
	mdg = default(mdg, false)
	lsb = default(lsb, false)
	lsb_in = default(lsb_in, false)
	input8 = lsb_in ? input.ditherpost(mode=7) : input
	super_filter = default(super_filter,4)
	pp_enabled = defined(pp)
	pp_lsb_in = default(pp_lsb_in,(pp_enabled ? lsb_in ? (height(input) == height(pp)) ? true : false : false : false ))
	lsb_enable = false
	recalculate = default(recalculate,true)
	truemotion = default(truemotion,true)
	Y = default(Y, true)
	U = default(U, true)
	V = default(V, true)
	tbsize = default(tbsize, mc * 2 + 1)
	dfttest_params = default(dfttest_params, "")
	blksize = default(blksize,16)
	blksize2 = int(blksize/2) + (int(blksize/2)%2)
	overlap = default(overlap,blksize2)
	overlap2 = int(overlap/2) + (int(overlap/2)%2)
	rStr          = default( rStr, 1.0 )
	Amp          = default( Amp, 0.0625 )
	# Set chroma parameters.
	chroma = U || V
	plane = U && !Y && !V ? 1 : V && !Y && !U ? 2 : chroma && !Y ? 3 : Y && chroma ? 4 : 0

	# Prepare supersampled clips.
	
	pp = (pp_enabled) ? pp.dither_luma_rebuild(S0=rStr,c=Amp,lsb_in=pp_lsb_in,lsb_out=false,uv=((U&&v)?3:1)) : nop()
	pp_super = pp_enabled ? MSuper(pp, pel=pel, chroma=chroma,rfilter=super_filter) : MSuper(input8, pel=pel, chroma=chroma)
	super = pp_enabled ? input8.MSuper(pel=pel, levels=1, chroma=chroma) : pp_super
	recalc_sup =  pp_enabled ? MSuper(pp,pel=pel, levels=1, chroma=chroma) : pp_super
	
	# Motion vector search.
	b5vec = MAnalyse(pp_super, delta=5, isb=true, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	b4vec = MAnalyse(pp_super, delta=4, isb=true, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	b3vec = MAnalyse(pp_super, delta=3, isb=true, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	b2vec = MAnalyse(pp_super, delta=2, isb=true, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	b1vec = MAnalyse(pp_super, delta=1, isb=true, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	f1vec = MAnalyse(pp_super, delta=1, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	f2vec = MAnalyse(pp_super, delta=2, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	f3vec = MAnalyse(pp_super, delta=3, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	f4vec = MAnalyse(pp_super, delta=4, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)
	f5vec = MAnalyse(pp_super, delta=5, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap, blksize=blksize, dct=dct,truemotion=truemotion)

	if(recalculate)
	{
	b5vec = MRecalculate(recalc_sup,b5vec , chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	b4vec = MRecalculate(recalc_sup,b4vec , chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	b3vec = MRecalculate(recalc_sup,b3vec , chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	b2vec = MRecalculate(recalc_sup,b2vec , chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	b1vec = MRecalculate(recalc_sup,b1vec , chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	f1vec = MRecalculate(recalc_sup,f1vec, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	f2vec = MRecalculate(recalc_sup,f2vec, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	f3vec = MRecalculate(recalc_sup,f3vec, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	f4vec = MRecalculate(recalc_sup,f4vec, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	f5vec = MRecalculate(recalc_sup,f5vec, chroma=chroma, search=search, searchparam=searchparam, overlap=overlap2, blksize=blksize2, dct=dct,thSAD=int(thSAD/2),truemotion=truemotion)
	}
	# Optional MDegrain.
	try {
		degrained = mc >= 3 && mdg ? MDeGrain3(input8, super, b1vec, f1vec, b2vec, f2vec, b3vec, f3vec, thSAD=mdgSAD, plane=plane, thSCD1=thSCD1, thSCD2=thSCD2, lsb=true) :
			\ mc == 2 && mdg ? MDeGrain2(input8, super, b1vec, f1vec, b2vec, f2vec, thSAD=mdgSAD, plane=plane, thSCD1=thSCD1, thSCD2=thSCD2, lsb=true) :
			\ mdg ? MDeGrain1(input8, super, b1vec, f1vec, thSAD=mdgSAD, plane=plane, thSCD1=thSCD1, thSCD2=thSCD2, lsb=true) : input
			degrained8 = lsb ? degrained.dither_get_msb() : degrained.ditherpost(mode=7)
			lsb_enable = true
		}
	catch(err_msg) {
		degrained8 = mc >= 3 && mdg ? MDeGrain3(input8, super, b1vec, f1vec, b2vec, f2vec, b3vec, f3vec, thSAD=mdgSAD, plane=plane, thSCD1=thSCD1, thSCD2=thSCD2) :
			\ mc == 2 && mdg ? MDeGrain2(input8, super, b1vec, f1vec, b2vec, f2vec, thSAD=mdgSAD, plane=plane, thSCD1=thSCD1, thSCD2=thSCD2) :
			\ mdg ? MDeGrain1(input8, super, b1vec, f1vec, thSAD=mdgSAD, plane=plane, thSCD1=thSCD1, thSCD2=thSCD2) : input8
		}
	degrained_super = mdg ? MSuper(degrained8, pel=pel, levels=1, chroma=chroma) : super
	b5clip = MCompensate(degrained8, degrained_super, b5vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	b4clip = MCompensate(degrained8, degrained_super, b4vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	b3clip = MCompensate(degrained8, degrained_super, b3vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	b2clip = MCompensate(degrained8, degrained_super, b2vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	b1clip = MCompensate(degrained8, degrained_super, b1vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	f1clip = MCompensate(degrained8, degrained_super, f1vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	f2clip = MCompensate(degrained8, degrained_super, f2vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	f3clip = MCompensate(degrained8, degrained_super, f3vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	f4clip = MCompensate(degrained8, degrained_super, f4vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
	f5clip = MCompensate(degrained8, degrained_super, f5vec, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)

	# Create compensated clip.
	interleaved = mc >= 5 ? Interleave(f5clip, f4clip, f3clip, f2clip, f1clip, degrained8, b1clip, b2clip, b3clip, b4clip, b5clip) :
		\ mc == 4 ? Interleave(f4clip, f3clip, f2clip, f1clip, degrained8, b1clip, b2clip, b3clip, b4clip) :
		\ mc == 3 ? Interleave(f3clip, f2clip, f1clip, degrained8, b1clip, b2clip, b3clip) :
		\ mc == 2 ? Interleave(f2clip, f1clip, degrained8, b1clip, b2clip) :
		\ Interleave(f1clip, degrained8, b1clip)
		degrainedmc=degrained.changefps(interleaved,linear=true)
		mask=mt_logic(interleaved,degrainedmc.dither_get_msb(), "xor",y=3,u=3,v=3).mt_binarize(0,y=3,u=3,v=3)
		interleaved = lsb_enable && lsb ? dither_merge16(degrainedmc,interleaved.dither_convert_8_to_16(),stackvertical(mask,mask),u=3,v=3) : interleaved #more optimized version than the one below
		#interleaved = lsb_enable ? dither_merge16_8(degrainedmc,interleaved.dither_convert_8_to_16(),mt_Lutxy(degrainedmc.ditherpost(mode=7),interleaved,"x y - 0 != 255 0 ?",u=3,v=3),u=3,v=3) : interleaved

		
	# Perform dfttest. Exception handling required for official dfttest.
	try {
		filtered = Eval("dfttest(interleaved, Y=Y, U=U, V=V, sigma=sigma, sbsize=sbsize, sosize=sosize, tbsize=tbsize, dither=dither, lsb=lsb,lsb_in=lsb_enable" + dfttest_params + ")")
		}
	catch(err_msg)
		{
		filtered = Eval("dfttest(interleaved, Y=Y, U=U, V=V, sigma=sigma, sbsize=sbsize, sosize=sosize, tbsize=tbsize, dither=dither" + dfttest_params + ")")
		}
		
	return selectEvery(filtered, mc * 2 + 1, mc)
}

# Converts luma (and chroma) to PC levels, and optionally allows tweaking for pumping up the darks. (for the clip to be fed to motion search only)
# By courtesy of cretindesalpes. (http://forum.doom9.org/showthread.php?p=1548318#post1548318)

function Dither_Luma_Rebuild (clip src, float "s0", float "c",int "uv", bool "lsb", bool "lsb_in", bool "lsb_out", int "mode"){
lsb_in  = Default( lsb_in  ,false)
lsb_out = Default( lsb_out ,false)
lsb     = Default( lsb     ,lsb_in || lsb_out)
mode    = Default( mode ,6)
uv      = Default(uv,    3)
s0      = Default(s0,  2.0)
c       = Default(c,  1.0/16)

	k = (s0 - 1) * c
	t = lsb_in ? "x 4096 - 56064 / 0 1 clip" : "x 16 - 219 / 0 1 clip"
	e = String(k)+" "+String(1+c)+" "+String((1+c)*c)+" "+t+" "+String(c)
\		+" + / - * "+t+" 1 "+String(k)+" - * + "+String(lsb?65536:255)+" *"
src
lsb ? (lsb_in ? Dither_lut16 (yexpr=e,expr="x 32768 - 32768 * 28672 / 32768 +",y=3, u=uv, v=uv)  : \
                Dither_lut8  (yexpr=e,expr="x 128 - 32768 * 112 / 32768 +"    ,y=3, u=uv, v=uv)) : \
                mt_lut       (yexpr=e,expr="x 128 - 128 * 112 / 128 +"        ,y=3, u=uv, v=uv)
lsb_out ? last : (lsb ? Ditherpost(mode=mode,u=uv,v=uv) : last)}