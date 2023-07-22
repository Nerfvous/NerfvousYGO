--Sigil of Bravery
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Cannot activate
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.inactcon)
    e2:SetOperation(s.inactop)
    c:RegisterEffect(e2)
    --Same effect as target
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(function(_,tp) return Duel.GetTurnPlayer()~=tp end)
    e3:SetTarget(s.cet)
    e3:SetOperation(s.ceop)
    c:RegisterEffect(e3)
    --Increase atk
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.atkcon)
    e3:SetTarget(s.atkt)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end
s.listed_series={0x28c}
code=58858807
function s.inactcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0x28a)
end
function s.inactop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.cefil(c,tp)
    if not (c:IsLinkMonster() and c:IsSetCard(0x28a) and c:IsHasEffect(code)) then
        return false
    end 
	local eff=c:GetCardEffect(code)
    local te=eff:GetLabelObject()
    local tg=te:GetTarget()
    if not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,eff,REASON_EFFECT,PLAYER_NONE,0) then
     return true end
    return false
end
function s.cet(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsCanBeEffectTarget(e) and chkc:IsFaceup() and chkc:IsControler(tp)
    and s.cefil(chkc) end
    if chk==0 then return
    Duel.IsExistingMatchingCard(aux.FaceupFilter(s.cefil,tp),tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local sc=Duel.SelectTarget(tp,aux.FaceupFilter(s.cefil,tp),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
    local te=sc:GetCardEffect(code):GetLabelObject()
    local tg=te and te:GetTarget() or nil
	if tg then
        e:SetLabel(te:GetLabel())
        e:SetLabelObject(te:GetLabelObject())
        e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
		tg(e,tp,eg,ep,ev,re,r,rp,1)
        e:SetLabelObject(te)
	end
	Duel.ClearOperationInfo(0)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
	if not te then return end
	local sc=te:GetHandler()
	if sc:GetFlagEffect(id)==0 then
		e:SetLabel(0)
		e:SetLabelObject(nil)
		return
	end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local spc=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x28c),tp,LOCATION_SZONE,0,nil)
    local g=Duel.GetMatchingGroup(s.spfil,tp,LOCATION_DECK,0,nil)
    if lc<1 or spc<1 or #g<1 then return end
    local num=math.min(lc,spc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,num,nil)
    if Duel.SpecialSummon(sg,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)>0 then
        --Can only special summon spellcasters from ED
        Duel.BreakEffect()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_SPELLCASTER) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
end
function s.atkt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return
    Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER)))
    e1:SetValue(s.atkval)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end
function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local num=g:GetClassCount(Card.GetAttribute)
    return 300*num
end