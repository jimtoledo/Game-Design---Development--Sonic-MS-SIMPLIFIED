pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
p_x=16
p_y=64
p_dx=0
p_dy=0
p_dir=false --p_dir=true means going left
p_animate=1
p_jump=false --airborne = true, on land = false
p_sprite_offset=1 --1 for normal, 0 for jump
num_rings=0

--for different map sections
p_map=false --p_map=true means bottom map
p_map_offset=0 --0 for top, 16 for bottom

p_iframe=false
p_iframecount=0

p_rip=false
p_win=false
p_wintext=false
p_wincount=0

function _init()
 cls()
	palt(0,false)
	palt(5,true)
	map(0,0,0,0,128,64)
	camera()
end

function win()
	if(p_x<496) then
		p_x+=p_dx
		p_animate += 1
		if(p_animate>5)p_animate=2
		return
	end
	if(p_animate!=1)p_animate=1
	if(p_wincount==15) mset(60,27,76)
	if(p_wincount==30) mset(61,27,77)
	if(p_wincount==45) mset(60,28,92)
	if(p_wincount==60) mset(61,28,93)
	if(p_wincount==75) p_wintext=true
	if(p_wincount==195) then
		p_rip=true
		p_dy=-8
		p_win=false
		p_wintext=false
	end
	p_wincount+=1
end

function pain()
	p_iframecount+=1
	if(p_iframecount%2==0)p_animate=6
	if(p_iframecount>90) then
		p_iframe=false
	end
end

function rip()
	p_y+=p_dy
	p_dy+=0.5
	if(p_dy>8)p_dy=8
	if(p_y>192) then
		map_reset()
	end
end


function map_reset()
	p_rip=false
	num_rings=0
	p_x=16
	p_y=64
	p_dx=0
	p_dy=0
	p_dir=false --p_dir=true means going left
	p_animate=1
	p_jump=false --airborne = true, on land = false
	p_sprite_offset=1 --1 for normal, 0 for jump
	p_map=false --p_map=true means bottom map
	p_map_offset=0 --0 for top, 16 for bottom
	reload(0x2000, 0x2000, 0x1000)
end

function jump()
	if(p_rip)return
	p_y+=p_dy
	collisions()
	p_animate+=1
	if(p_animate>3)p_animate=1
	if(p_dy<8)p_dy+=0.6
	if(fget(mget(flr(p_x/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset),1) or (p_dy>0 and (fget(mget(flr(p_x/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset),0) or fget(mget(flr(p_x/8)+1,ceil(p_y/8)+1+p_sprite_offset+p_map_offset),0)))) then
		slope_fix()
		p_jump=false
		p_sprite_offset=1
		p_dy=0
		p_y=ceil(p_y/8-1)*8
		--slope_fix()
	end
end

function slope_fix()
	if(p_rip)return
	if(p_jump and p_dy<0)return
	if(mget(flr(p_x/8),ceil((p_y+1)/8)+p_sprite_offset+p_map_offset)==65 or mget(ceil(p_x/8),ceil((p_y+1)/8)+p_sprite_offset+p_map_offset)==65) p_dy=0.1
	
	if(mget(flr(p_x/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset)==65 or mget(ceil(p_x/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset)==65) then
		p_y=ceil(p_y/8)*8
	end
	m=mget(flr(p_x/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset)
	n=mget(flr(p_x/8)+1,ceil(p_y/8)+1+p_sprite_offset+p_map_offset)
	if(fget(m,7) or fget(n,7)) then
		while true do
			for i=flr(p_x),flr(p_x+7) do
				in_ground=false
				p=pget(i,p_y+8+(p_sprite_offset*8))
				if(p==3 or p==4 or p==9 or p==11) then
					in_ground=true
					break
				end
			end
			if(in_ground) then
				break
			else p_y+=1 end
		end
	end
	if((fget(m,7) or fget(n,7)) and m!=72 and n!=72 and m!=88 and n!=88) then
		while true do
			for i=flr(p_x),flr(p_x+7) do
				in_ground=false
				p=pget(i,p_y+7+(p_sprite_offset*8))
				if(p==3 or p==4 or p==11) then
					in_ground=true
					break
				end
			end
			if(in_ground) then
				p_y-=1
			else break end
		end
	end
end

function collisions()
	if(p_rip)return
	p_ub=mget(ceil((p_x)/8),ceil(p_y/8)+p_map_offset) --upper body collision sprite
	p_lb=mget(ceil((p_x)/8),ceil(p_y/8)+p_sprite_offset+p_map_offset) --lower body collision sprite
	p_top=mget(ceil((p_x/8)),ceil(p_y/8)-1+p_map_offset)
	p_bottom=mget(ceil((p_x/8)),ceil(p_y/8)+1+p_sprite_offset+p_map_offset) --surface sonic is on
	
	--floored body collision
	p_ubf=mget(flr((p_x-1)/8),ceil(p_y/8)+p_map_offset)
	p_lbf=mget(flr((p_x-1)/8),ceil(p_y/8)+p_sprite_offset+p_map_offset)
	p_topf=mget(flr((p_x-1)/8),ceil(p_y/8)-1+p_map_offset)
	p_bottomf=mget(flr((p_x-1)/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset)
	
	p_topm=mget(flr((p_x-1)/8)+1,ceil(p_y/8)-1+p_map_offset)
	p_bottomm=mget(flr((p_x-1)/8)+1,ceil(p_y/8)+1+p_sprite_offset+p_map_offset)

	--coins
	if(p_ub==115) then
		mset(ceil((p_x)/8),ceil(p_y/8)+p_map_offset,0)
		num_rings+=1
	end
	if(p_lb==115 and not p_jump) then
		mset(ceil((p_x)/8),ceil(p_y/8)+p_sprite_offset+p_map_offset,0)
		num_rings+=1
	end
	if(p_ubf==115) then
		mset(flr((p_x-1)/8),ceil(p_y/8)+p_map_offset,0)
		num_rings+=1
	end
	if(p_lbf==115 and not p_jump) then 
		mset(flr((p_x-1)/8),ceil(p_y/8)+p_sprite_offset+p_map_offset,0)
		num_rings+=1
	end
	if(mget(ceil(p_x/8),flr((p_y-7)/8)+p_map_offset)==115) then
		mset(ceil(p_x/8),flr((p_y-7)/8)+p_map_offset,0)
		num_rings+=1
	end
	if(mget(flr((p_x-1)/8),flr((p_y-7)/8)+p_map_offset)==115) then
		mset(flr((p_x-1)/8),flr((p_y-7)/8)+p_map_offset,0)
		num_rings+=1
	end


	--wall stuff
	if(p_ub==89 or p_ub==118 or p_lb==89 or p_ub==118 or p_ubf==89 or p_ubf==118 or p_lbf==89 or p_ubf==118) then
		if(p_dx>0)p_dx=0
		p_x=ceil(p_x/8-1)*8
	end
	if(p_ub==90 or p_ub==119 or p_lb==90 or p_lb==119 or p_ubf==90 or p_ubf==119 or p_lbf==90 or p_lbf==119) then
		if(p_dx<0)p_dx=0
		p_x=flr((p_x-1)/8+1)*8
	end
	
	--powerup stuff
	if(fget(p_ubf,1) or fget(p_lbf,1)) then
		if(p_dx<0) then
			p_dx=0
			p_x=flr((p_x-1)/8+1)*8
		end
	elseif(fget(p_ub,1) or fget(p_lb,1)) then
		if(p_dx>0) then
			p_dx=0
			p_x=ceil(p_x/8-1)*8
		end
		if(p_dx<0) then
			p_dx=0
			p_x=flr((p_x-1)/8+1)*8
		end
	elseif(fget(p_top,1) or fget(p_topf,1) or fget(p_topm,1)) then
		p_dy=2
		p_y=ceil(p_y+1/8)
		if(not p_jump) then
			p_jump=true
			p_sprite_offset=0
		end
	elseif(fget(p_bottom,1) or fget(p_bottomf,1) or fget(p_bottomm,1)) then
		if(not p_jump) then
			if(p_bottom==116 or p_bottomf==116) num_rings+=10 --super ring
			p_y=flr(p_y/8)*8
			if(fget(p_bottom,1)) then
				mset(ceil((p_x/8)),ceil(p_y/8)+1+p_sprite_offset+p_map_offset,106)
				if(p_bottom==123)mset(ceil((p_x/8)),flr(p_y/8)+1+p_sprite_offset+p_map_offset,107)
			elseif(fget(p_bottomf,1)) then
				mset(flr((p_x-1)/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset,106)
				if(p_bottomf==123)mset(flr((p_x-1)/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset,107)
			elseif(fget(p_bottomm,1)) then
				mset(flr((p_x-1)/8)+1,ceil(p_y/8)+1+p_sprite_offset+p_map_offset,106)
				if(p_bottomm==123)mset(flr((p_x-1)/8)+1,ceil(p_y/8)+1+p_sprite_offset+p_map_offset,107)
			end
			
			p_jump=true
			p_sprite_offset=0
			p_dy=-4.5
		end
	end
	
	--spikes
	if(fget(p_ub,2) or fget(p_lb,2) or fget(p_ubf,2) or fget(p_lbf,2)) then
		if(not p_iframe) then
			if(num_rings>0) then
				num_rings=0
				p_iframecount=0
				p_iframe=true
			else
				p_rip=true
				p_dy=-8
				--die
			end
		end
	end
	
	--win sign
	if(fget(p_ub,4) or fget(p_lb,4) or fget(p_ubf,4) or fget(p_lbf,4)) then
		if(p_win) return
		p_win=true
		p_wincount=0
		p_animate=1
		p_dx=2
	end
end

function _update()
	if(p_rip) then
		rip()
		return
	end
	if(p_win) then
		win()
		return
	end
	if(not p_jump) then
		if(p_dx==0 and not(btn(0) or btn(1))) then
			p_animate=1
		else
			p_animate += 1
			if(p_animate>5)p_animate=2
		end
		if(not(btn(0) or btn(1))) then
			m=mget(flr(p_x/8+0.5),ceil(p_y/8)+1+p_sprite_offset+p_map_offset)
			if(fget(m,6)) then
				if(p_dx<0)p_dx+=0.5
				p_dx=min(p_dx+0.1,2)
			elseif(fget(m,5)) then 
				if(p_dx>0)p_dx-=0.5
				p_dx=max(p_dx-0.1,-2)
			else
				if(p_dx>0)p_dx=max(p_dx-0.2,0)
				if(p_dx<0)p_dx=min(p_dx+0.2,0)
			end
		end
	end
	if(btn(0)) then
		p_dx=max(p_dx-0.15,-3.5)
		if(p_dx>0) then
			if(not p_dir) then
				p_dx-=0.6
				p_dir=true
				else p_dx-=0.1
			end
		end
		if(not p_dir)p_dir=true
	end
	if(btn(1)) then
		p_dx=min(p_dx+0.15,3.5)
		if(p_dx<-5)p_dx+=1 --spring
		if(p_dx<0) then
			if(p_dir) then
				p_dx+=0.6
				p_dir=false
			else p_dx+=0.1
			end
		end
		if(p_dir)p_dir=false
	end
	if(btn(4)) then
		if(not p_jump) then
			collisions()
			p_jump=true
			p_sprite_offset=0
			p_dy=-6
		end
	end
	p_ub=mget(ceil((p_x)/8),ceil(p_y/8)+p_map_offset) --upper body collision sprite
	p_lb=mget(ceil((p_x)/8),ceil(p_y/8)+p_sprite_offset+p_map_offset) --lower body collision sprite
	p_top=mget(ceil((p_x/8)),ceil(p_y/8)-1+p_map_offset)
	p_bottom=mget(ceil((p_x/8)),ceil(p_y/8)+1+p_sprite_offset+p_map_offset) --surface sonic is on
	
	--floored body collision
	p_ubf=mget(flr((p_x-1)/8),ceil(p_y/8)+p_map_offset)
	p_lbf=mget(flr((p_x-1)/8),ceil(p_y/8)+p_sprite_offset+p_map_offset)
	p_bottomf=mget(flr((p_x-1)/8),ceil(p_y/8)+1+p_sprite_offset+p_map_offset)
	p_topf=mget(flr((p_x-1)/8),ceil(p_y/8)-1+p_map_offset)
	
	if(p_ub==114 or p_lb==114) p_dx=-7.5
	
	slope_fix()
	
	if(not(fget(p_bottom,0) or fget(p_lb,0) or fget(p_bottomf,0) or fget(p_lbf,0))) then
		if(not p_jump) then
			p_jump=true
			p_sprite_offset=0
			p_dy=0.8
		end
	end
	
	collisions()
	if(p_jump) jump()
	
	p_x+=p_dx
	
	if(p_x<0) then
		if(p_map) then
			p_x=1016
			p_map_offset=0
			p_map=false
		else
			p_x=0
			p_dx=0
		end
	end
	
	if(p_x>1024) then
		p_x=0
		p_map_offset=16
		p_map=true
	end
	
	if(p_iframe)pain()
	
	slope_fix()
	
end

function _draw()
	cls()
	cam_x=mid(0,p_x-32,896)
	cam_y=mid(-64,p_y-56,0)
	--skybox
	camera(cam_x/3,cam_y+64)
	map(0,32,0,0,128,24)
	--map
	camera(cam_x,cam_y)
	map(0,p_map_offset,0,0,128,16)
	if(p_rip) then
		spr(7,p_x,p_y,2,2)
	else
		if(p_jump) then
			spr(16*p_animate,p_x,p_y,1,1,p_dir)
		else
			spr(p_animate,p_x,p_y,1,2,p_dir)
		end
	end
	--coin count
	camera(0,0)
	spr(115,0,0)
	print(""..num_rings,10,1,7)
	if(p_wintext) then
		print("YOU WIN!",32,64,7)
	end
	camera(cam_x,cam_y)
end
__gfx__
55555555511155155111551551115515511155155111551555555555555551151111555555555000000000000000000000000000000000000000000000000000
555555551ccc11c11ccc11c11ccc11c11ccc11c11ccc11c15555555555551cc1ccc1555555555000000000000000000000000000000000000000000000000000
55555555ccfcccc1ccfcccc1ccfcccc1ccfcccc1ccfcccc1555555555551cccccf15555555555000000000000000000000000000000000000000000000000000
555555551cfc77611cfc77611cfc77611cfc77611cfc7761555555555551c77c77c1555555555000000000000000000000000000000000000000000000000000
555555551cc770701cc770701cc770701cc770701cc77070555555555555170707c1555555555000000000000000000000000000000000000000000000000000
5555555551cf707f51cf707f51cf707f51cf707f51cf707f5555555557651fffffc1675555555000000000000000000000000000000000000000000000000000
55555555551fffff551fffff551fffff551fffff551fffff55555555767551f0f115767555555000000000000000000000000000000000000000000000000000
5555555555111ff555111ff555111ff555111ff555111ff55555555557f555111555f75555555000000000000000000000000000000000000000000000000000
551111555551f1155551f1155551f1155551f1155551f11555555555555f558f855f555555555000000000000000000000000000000000000000000000000000
51cccc155558f7855558f7865558f7865558f7865558f786555555555555f87778f5555555555000000000000000000000000000000000000000000000000000
1c7cccc15568778655f8668755f8668755f8668755f8668755555555555558777855555555555000000000000000000000000000000000000000000000000000
17ccccd1577cff67555f77c6555f77c6555f77c6555f77c65555555555555cf7fc55555555555000000000000000000000000000000000000000000000000000
17ccccd15661cc1558816c5557816c5558716c5558816c5555555555555551ccc155555555555000000000000000000000000000000000000000000000000000
1ccccdd1555155155715518558155185581551855815518555555555555515555515555555555000000000000000000000000000000000000000000000000000
51cddd15555155155811517558115185581151855711518555555555555515555515555555555000000000000000000000000000000000000000000000000000
55111155555a85a85588888555888785558878855578888555555555555875555578555555555000000000000000000000000000000000000000000000000000
55111155555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
51c7cc15555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
1c7cccc1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
17ccccd1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
1cccccd1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
1ccccdd1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
51cddd15555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55111155555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55111155555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
51c77c15555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
1c7cccc1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
1cccccd1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
1cccccd1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
1ccccdd1555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
51cddd15555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55111155555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
444499993bbb3bbb355555553b5555555555555555555555555555b35555555b5555555544449999555555555555555555555555555555555555555555555555
444499993bbb3bbb3b5555553bbb555555555555555555555555bbb0555555b35555555544449999555555555555555556666666666666655555555555555555
444499993bbb3bbb0bb5555503bb3b55555555555555555555b3bb3055555bb3555555554444999955555555555555556aaa91119919aaa65555555555555555
4444999903b303b303bb555503bb03bb5555555555555555bb30bb0455550bb3555555554444999955555555555555556aa91ccc11c19aa65555555555555555
9999444403b303b303b3055503b303bb3b555555555555b3bb303b04555b0bb3555555b39999444455555555555555556aa9ccfcccc19aa65555555555555555
999944449030403003b30b5590b303bb03bb55555555bb30bb303b0455b30b305555bb309999444455555555555555556aa91cfc77619aa65555555555555555
999944449909440403b003b590b040b303bb3b5555b3bb303b090b045bb30b3055b3bb309999444455555555555555556aa91cc770709aa65555555555555555
9999444499994444903040b0903040b090bb03bbbb30bb040b090304bbb303045b30bb049999444455555555555555556aaa91cf707f9aa65555555555555555
9444999944449994440490b04404903040b303bbbb303b09030490993b3090993b303b095555555555555555555555556aaaa91fffff9aa65555555555555555
4944999944449949444490b044449909403090bb3b040309404499990b3099993b0403095555555555555555555555556aaaa9111ff9aaa65555555555555555
94449999444499944444903044449999440490b33b049099444499990b3099993b0490995555555555555555555555556aaaaa99999aaaa65555555555555555
49449999444499494444990944449999444490300b049999444499990b3099990b04999955555555555555555555555556666666666666655555555555555555
94994444999944949999444499994444999944040309444499994444030944440309444455555555555555555555555555555556655555555555555555555555
49994444999944499999444499994444999944449099444499994444909944444099444455555555555555555555555555555556655555555555555555555555
94994444999944949999444499994444999944449999444499994444999944449499444455555555555555555555555555555556655555555555555555555555
49994444999944499999444499994444999944449999444499994444999944444999444455555555555555555555555555555556655555555555555555555555
55555555cccccccc1111111111111111111111111111111153bb3bbb3bbb3b351111111111111111555555554444999955555555555555555555555555555555
55555555cccccccc111111111111a11111117111111166113bbb3bbb3bbb3bb31117111111111111555555554444999956666666666666655555555555555555
55555555cccccccc111111111111111111711111661111163bbb3bbb3bbb3bb3111111771111111155555555444499996aaaaaa888aaaaa65550555555555555
55555555cccccccc1111111111a11111111111711116611103b303b303b303b3111117aa7111111155555555444499996aaaaa88888aaaa65557055555555555
55555555cccccccc11111111111111a1111171116161111103b303b303b303b311117aa71111111155555555999944446aaaaa88a88aaaa65557055555555555
55555555cccccccc1111111111111111111111111116166640304030903040301117aaa71111111165555566699944666aaaaaaa888aaaa65557055555555555
55555555cccccccc111111111a111111117111111661111194094404990944041117aaa71117111160060006600600066aaaaaa888aaaaa65576d05555555555
55555555cccccccc1111111111111111111111111111111149994444999944491117aaaa777a711166666666666666666aaaaaa88aaaaaa65576d05555555555
555555554444444494405555550000556666666666666666944499994444999411177aaaaaaa711166666666666666666aaaaaaaaaaaaaa65576d05555555555
55555555aaaaaaaaaaa0005050aaaa05600aa00660000006494499994444994911117aaaaaa7111160000006600000066aaaaaa88aaaaaa65576d05555555555
5555555590777d9077aa0c0c07700aa060a00906600c000694449999444499941111177aaa71111160007706600990066aaaaaa88aaaaaa65576d05555555555
55555555007dd0007aaa0c0c070500a067000096607007064944999944449949171111777711111160007706600990065666666666666665576ddd0555555555
55555555aa7dd0aaa9990101070500a06a000096600000069499444499994494111111111111111160089806609999065555555665555555576ddd0555555555
5555555544444444a99901010aa00aa060a00a06600700064999444499994449111111111111171160889806600990065555555665555555576ddd0555555555
55555555040404049990005050aaaa05600aa00660c000069499444499994494111111711111111160000006600000065555555665555555576ddd0555555555
5555555500000000944055555500005566666666666666664999444499994449111111111111111166666666666666665555555665555555576ddd0555555555
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626462626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262646262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262636262626262626262626262626262626262626263626262626262626462626262626262626262626262626362626264626262626262626262626
36262626462626262636262626262626262626262626262646262626262626262626262626262626262646262626262636262626262626262626262646262626
26262626262626262626262626262626262646262626262626462626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626362626262626262626262626262626262626262626262626262626262626262636262626262626262626262626
26262646262626262626262626263626262626262626262626262626262626262626262626262626262626462626262626262626262626262626262626262636
26262626262626262626262626264626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262636262626262626462626262626262626262626262626262626262626262626262636262626262626262626262626262626262626262626262626262646
26262626262626262626262636262626262626262626262626262626262626262626264626262626262626262626264626262626262626263626262626262626
26262626262626262626262626262626262626262626262626262626262626262626462626262626262626262626262636262626262626362626262626262626
26262626262626262626262626262626262626262626263626262626262626262626262626262626262626262626262626262626262626262626462626262626
26262626262626262626262626262626262626263626262626262626262626262626262626262626262626262626262626262626462626262626262626262626
26262626262626262646262626262626262626262626262626262626262626262626262626262626262626262626263626262626262626262626262626262626
26262626262626262636262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626362626262626262636262626262626262626264626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262686962626263626262626462626262626262626262626262646262626262626262626262686962626262626262626262626262626262626262626262636
26262626462626262626262626262626262686962626262626262626262626262626262626262626362626262646262626268696262626262626262626362626
26262687972646262626262626262626362626262626462626262626262636262626262646262687973626262626462626262626262626262626262626462626
26262626262626362626262626462626262687972626264626262626262626262626262626264626262626262626262636268797262626462626262626262626
26362626262626262626262626462626262626262626262626263646262626262626262626262626362626262626262626362626262626263626262626262626
26262626462626262626262626262626263626262626262626263626262626262636262626262626262626262646262626262626262626262626362626262626
26262626262626262626262626262626362626262626362626262626262636262626262636262626262626262626462626262626262626262626262626262626
26262626262626362626262626362626262626262626264626262626262626262626262626262626262626262626262636262626262626462626262626262626
26262626262626262626362626262626262626262626262626262626262626262626262626262626262626262626262626362626262626262626262626262626
26362626262626262626262626262626262626262626262626263626262626262626262626262626262636262626262626262626262626262626362626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626362626262626262626262626262626262626262626
26262626262626262626262626262626262626263626262626262626262626262626262626262626262626262626262626262626362626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
56565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
56565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
26262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
16161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c1c1c1a1a1a1a1010000000000000000c1c1c1a1a1a1a1000000000000000400000000000101000000001010040004010000030308080000030310100400
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000073737300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000073730000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000073730000000000000000
0000000000000000000000000000000000740000000000000000000000000000000000000073730000000000000000000000000000000000000000000000737373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000737300000066416700000073730000000000000000000000000000000000000000750000000000000000000000000000000073737373730000000000000000000000000000000000000000000073737300000000000000000000000000000000000000737373730000000000000045464141414141
0000000000000000000000000000000050405100000000000000000000000000007373000000000000454641414142000000000000000000000000000000000000000000000000007373000000000000737300000000000000000000000000000000000000000000000000000000000000000000000000454655564040404040
0000000000000000000000000000000050405100000000000000000000000000000000000000004546555640404052420000000000000000000000000000000000000000000000000000000000000000000000000000000073737300000000000000000000000000004546416700000000000000004546555640404040404040
0000000000000000000000000000000050405100000000000000000000000000000000000045465556404040404040524200000000000000000000000000007a00000000000000000000000000000000000000000000000000000000000000000000000000000045465556405100007171000066415556404040404040404040
0000000000000000004546414141414141414141414200000073737373000000000000454655564040404040404040405242000000000073730000000066414141670000006641670000000000000000664143440000000000000000004546420000000000664155564040405100000000000076404040404040404040404040
0000000000000045465556404040404040404040495242000000000000000000004546555640404040404040404040404052420000000000000000000050404040510000007640770000000000000000764053544344004546414141415556524200000000504040404040405100000000000076404040404040404040404040
4141414141414155564040404040404040404040404952420000000000000045465556404040404040404040404040404040524200000000000000000050404040510000007640770000007171000000764040405354415556404040404040405242000000504040404040405100000000000076404040404040404040404040
4040404040404049404040404040404040404040404049524200000000454655564040404040404040404040404040404040405242000000000000000050404040510000727640770000000000000000764040404040404040404040404040404052420000504040404040405100000000000076404040404040404040404040
40404040404040404040404040404040404040404040404952414141415556404040404040404040404040404040404040404040524141414141414141414141414141414176407700000000000000007640404040404040404040404040404040405242005040404040407b5100000000000076404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040407640776e6e6e6e6e6e6e6e76404040404040404040404040404040404040524141414141414141676e6e6e6e6e6e76404040404040404040404040
4949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949497640777e7e7e7e7e7e7e7e76494949494949494949494949494949494949494949494940404040777e7e7e7e7e7e76494949494949494949494949
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040407640774141414141414141764040404040404040404040404040404040404040404040404040407741414141414176404040404040404040404040
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
0000007373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
0000000000000000000000000000000000000000730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4141414141414344000000000000000000000073007300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040405354434400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040535443440000000000000066414167000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404053544344000000000050404051000000000000000000000000737300000000000000007373730000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040405354434400000050404051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040535443440050404051000000000000000000000000000000000000000000007373730000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404053544141414141670000717100000000006641414141414143440000000000000000000000000000000000000000000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040770000000000000000007640404040404053544344000000000000000000000000000000006c6d000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040776e6e6e6e6e6e6e6e6e7640404040404040405354434400000000000000000000000000007c7d000000000000000000000000000000000000764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040777e7e7e7e7e7e7e7e7e7640404040404040404040535441414141414141414141414141414141414141414141414141414141414141414141764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4949494949494949494949494949494949494949494949774141414141414141417649494949494949494949494949494940404040404040404040404040404040404040404040404040404040404040764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040774040404040404040407640404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040764040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
