-- joins ACTIVE line with the next one. it's a combination of "Join (concatenate)" and "Join (keep first)"
-- if the text (without tags) is the same on both lines, then it's "keep first"
-- if text is different, it's "concatenate", but it nukes some redundant tags from the 2nd line
-- if a bigger selection has the same visible text on all lines, works as "Join (keep first)" for the whole selection
-- set a simple hotkey to use when timing

script_name = "Join"
script_description = "Join lines"
script_author = "unanimated"
script_version = "1.3"

function join(subs, sel, act)
    go=0
    if #sel>1 then
	go=1	st=10000000  et=0
	for x, i in ipairs(sel) do
	  l=subs[i]	  t=l.text	ct=t:gsub("{[^}]-}","")
	  stm=l.start_time etm=l.end_time
	  if stm<st then st=stm end
	  if etm>et then et=etm end
	  if x>1 and ct~=ref then go=0 end
	  ref=ct
	end
    end
    if go==1 then
	l=subs[sel[1]]
	l.start_time=st	l.end_time=et
	subs[sel[1]]=l
	for i=#sel,2,-1 do subs.delete(sel[i]) end
	sel={sel[1]}
    else
	if act==#subs then aegisub.log("Nothing to join with.") aegisub.cancel() end
        l=subs[act]		t=l.text	ct=t:gsub("{[^}]-}","")
	l2=subs[act+1]		t2=l2.text	ct2=t2:gsub("{[^}]-}","")	ct3=t2:gsub("^{[^}]-}","")    :gsub("^%- ","")

	if ct~=ct2 then 
	  t=t:gsub("{[Jj][Oo][Ii][Nn]}%s*$","")
	  tt=t:match("^{\\[^}]-}")
	  tt2=t2:match("^{\\[^}]-}")
	  if tt~=nil and tt2~=nil then 
	    tt=tt:gsub("\\pos%([^%)]-%)","")
	    tt2=tt2:gsub("\\pos%([^%)]-%)","")
	    if tt==tt2 then t=t.." "..ct3 else 
	    tt2=tt2:gsub("\\an%d","")
	    :gsub("\\pos%([^%)]-%)","")
	    :gsub("\\move%([^%)]-%)","")
	    :gsub("\\fade?%([^%)]-%)","")
	    :gsub("\\org%([^%)]-%)","")
	    :gsub("\\i?clip%([^%)]-%)","")
	    :gsub("\\q%d","")
	    :gsub("{}","")
	    t=t.." "..tt2..ct3 end
	  elseif tt2~=nil then
	    t=t.." "..tt2..ct3
	  else
	    t=t.." "..ct3
	  end
	end
	if l2.end_time>l.end_time then l.end_time=l2.end_time end
	subs.delete(act+1)
	l.text=t
        subs[act]=l
    end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, join)