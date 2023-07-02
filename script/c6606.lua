--Tea Party Guest - Hanako
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Add pendulum procedure
    Pendulum.AddProcedure(c)
    --Cannot use as materials
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_MOVE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.ccond)
    e1:SetTarget(s.ctarget)
    e1:SetOperation(s.coperation)
    c:RegisterEffect(e1)
    --Can be used as Link material from Pendulum Zone
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetOperation(s.extracon)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
    --Special summon from hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	c:RegisterEffect(e3)
    --Lose atk
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,3})
    e4:SetTarget(s.atktc)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
end
s.listed_series={0x294}
function s.ccond(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_PZONE) and c:IsFaceup()
end
function s.cfilter(c)
    return c:IsType(TYPE_MONSTER)
end
function s.ctarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and s.cfilter(chkc)
        and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanBeEffectTarget(e)
        and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,1,nil)
end
function s.coperation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        --refer to c6605 with similar effect
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
        e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
        tc:RegisterEffect(e1)
    end
end
function s.extracon(c,e,tp,sg,mg,lc,chk)
	return sg:FilterCount(s.flagcheck,nil)<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap[c]) do
			eff:Reset()
		end
		s.flagmap[c]={}
	end
end
function s.cfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
    and c:IsRace(RACE_FAIRY) end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.cfilter),c:GetControler(),LOCATION_PZONE,0,1,nil)
end
function s.atkfil(c,tp)
    return c:IsType(TYPE_MONSTER) and c:IsControler(tp)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.gfil(c)
    return c:IsMonster()
end
function s.atktc(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsCanBeEffectTarget(e) and s.atkfil(chkc,tp)
    end
    if chk==0 then return Duel.IsExistingTarget(s.atkfil,tp,LOCATION_MZONE,0,1,nil,tp)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.gfil),tp,0,LOCATION_MZONE,1,nil,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    --Duel.SelectTarget(sel_player, f, player, s, o, min, max)
    local tc=Duel.SelectTarget(tp,s.atkfil,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
    local dmgl=-(tc:GetAttack())
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,dmgl)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc and not tc:IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,nil,tp)
    local dmgl=-(tc:GetAttack())
    for ct in aux.Next(g) do
        local e1=Effect.CreateEffect(ct)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetValue(dmgl)
        ct:RegisterEffect(e1)
    end
    --Duel.IsExistingMatchingCard(f, player, s, o, count, ex, ...)
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(s.atkfil,tp),tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsPlayerCanDraw(tp) then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
