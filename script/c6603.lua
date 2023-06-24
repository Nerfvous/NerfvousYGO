--Tea Party Guest - Hifumi
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Add pendulum procedure
    Pendulum.AddProcedure(c)
    --Cannot attack
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_MOVE)
    e1:SetTarget(s.gtarget)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetOperation(s.goperation)
    e1:SetCondition(s.cond)
    c:RegisterEffect(e1)
    --Light monsters gain 300 atk/def
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
    e2:SetValue(300)
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
	--e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.spcon)
	c:RegisterEffect(e4)
    --Place "Tea Party" monsters to pendulum zone
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetCountLimit(1,{id,2})
    e5:SetTarget(s.montg)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCost(s.moncost)
    e5:SetOperation(s.monopr)
    c:RegisterEffect(e5)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
    local e6=e5:Clone()
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e6)
end
s.listed_series={0x294}
function s.gfilter(c)
    return c:IsMonster() end
function s.gtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) 
        and chkc:IsFaceup() and chkc:IsCanBeEffectTarget(e) and s.gfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(s.gfilter),tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,aux.FaceupFilter(s.gfilter),tp,0,LOCATION_MZONE,1,2,nil)
end
function s.goperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetTargetCards(e)
    local sg=tc:GetFirst()
    for sg in aux.Next(tc) do
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(id,1)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sg:RegisterEffect(e1)
    end
end
function s.cond(e)
    local c=e:GetHandler()
    --Debug.Message(c:GetReason()==0)
    --Debug.Message(c:IsReason(REASON_EFFECT))
    return c:IsLocation(LOCATION_PZONE) and c:IsFaceup()
        and (c:IsReason(REASON_SPSUMMON) or c:GetReason()==0)
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
    return c:IsSetCard(0x294) and c:IsMonster()
end
function s.cfilter3(c,tp)
    return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.cfilter4(c)
    return c:IsSetCard(0x294) and c:IsLevel(4)
end
function s.montg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckPendulumZones(tp)
        --and Debug.Message(Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.cfilter2),tp,LOCATION_GRAVE,0,1,nil,tp))
        --and Debug.Message(Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_EXTRA,0,1,nil,tp))
        and (Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_EXTRA,0,1,nil,tp)
        or Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.cfilter2),tp,LOCATION_GRAVE,0,1,nil,tp))
        end
    Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0,nil)
end
function s.monopr(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckPendulumZones(tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
    if tc and Duel.MoveToField(tc,tp,0,LOCATION_PZONE,POS_FACEUP,true) 
    and Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_MZONE,0,1,nil)
    and Duel.IsExistingMatchingCard(s.cfilter4,tp,LOCATION_DECK,0,1,nil)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummon(tp)
    and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        --Duel.MoveToField(tc,tp,0,LOCATION_PZONE,POS_FACEUP,true)
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local sc=Duel.SelectMatchingCard(tp,s.cfilter4,tp,LOCATION_DECK,0,1,1,nil)
        --Duel.SpecialSummon(targets, sumtype, sumplayer, target_player, nocheck, nolimit, pos)
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.moncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT)
end
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT))
end