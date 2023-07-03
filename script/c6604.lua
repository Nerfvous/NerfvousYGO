--Tea Party Guest - Azusa
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Add pendulum procedure
    Pendulum.AddProcedure(c)
    --Destroy 1 Spell/Trap
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_MOVE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetTarget(s.gtarget)
    e1:SetCountLimit(1,{id,0})
    e1:SetOperation(s.goperation)
    e1:SetCondition(s.gcond)
    c:RegisterEffect(e1)
    --Non-light monsters loses 300 atk/def
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(function(_,c) return c:IsMonster() and not c:IsAttribute(ATTRIBUTE_LIGHT) end)
    e2:SetValue(-300)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    --Special summon from hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.spcon)
	c:RegisterEffect(e4)
    --Place "Tea Party" monsters to pendulum zone
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,2})
    e5:SetTarget(s.montg)
    e5:SetOperation(s.monopr)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e6)
end
s.listed_series={0x294}
function s.gfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.gtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() and s.gfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.gfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.gfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.goperation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.gcond(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --local rc=re:GetHandler()
    --Debug.Message(rc)
    --Debug.Message(c:GetReason())
    --Debug.Message(c:IsLocation(LOCATION_PZONE))
    --Debug.Message(c:GetReasonCard())
    --Debug.Message(Duel.GetChainEvent(0))
    --Debug.Message()
    --Debug.Message(re)
    --Debug.Message(c:IsType(TYPE_EFFECT))
    --Debug.Message(Duel.GetOperatedGroup())
    --Debug.Message(ev)
    return c:IsLocation(LOCATION_PZONE) and c:IsFaceup()
    and not c:IsPreviousLocation(LOCATION_HAND)
end
function s.gloses(c)
    return not c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.cfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
    and c:IsRace(RACE_FAIRY) end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.cfilter),c:GetControler(),LOCATION_PZONE,0,1,nil)
end
function s.cfilter2(c)
    return c:IsSetCard(0x294)
end
function s.cfilter3(c)
    return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.cfilter4(c)
    return c:IsMonster() --and c:IsCanBeEffectTarget(e)
end
function s.montg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSendtoHand(tp)
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.cfilter2),tp,LOCATION_GRAVE,0,1,nil,tp)
        end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,0,0,nil)
end
function s.monopr(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanSendtoHand(tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
    if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT)
    and Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_MZONE,0,1,nil)
    and Duel.IsExistingMatchingCard(s.cfilter4,tp,0,LOCATION_MZONE,1,nil)
    and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local sc=Duel.SelectMatchingCard(tp,s.cfilter4,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
        local atk=sc:GetBaseAttack()
        if atk<0 then
            atk=0 end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-atk)
		sc:RegisterEffect(e1)
    end
end