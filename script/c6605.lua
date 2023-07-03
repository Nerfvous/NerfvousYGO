--Tea Party Guest - Koharu
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Add pendulum procedure
    Pendulum.AddProcedure(c)
    --Gain LP
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_MOVE)
    e1:SetTarget(s.rctg)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetOperation(s.rcop)
    e1:SetCondition(s.rccon)
    c:RegisterEffect(e1)
    --Inflict damage
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTarget(s.dmgtg)
    e2:SetOperation(s.dmgop)
    e2:SetCondition(s.dmgcon)
    c:RegisterEffect(e2)
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
    --2nd attack
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,2})
    e5:SetTarget(s.datkt)
    e5:SetOperation(s.datkop)
    c:RegisterEffect(e5)
end
s.listed_series={0x294}
function s.rcfilter(c)
    return c:IsMonster()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard
        (aux.FaceupFilter(s.rcfilter),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
    local hatk=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    :GetMaxGroup(Card.GetAttack):GetFirst()
    local atkval=hatk:GetAttack()
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(atkval)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atkval)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
function s.rccon(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_PZONE) and c:IsFaceup()
end
function s.tpfil(c,tp)
    return c:IsControler(tp) and c:IsStatus(STATUS_OPPO_BATTLE)
    and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
    and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=eg:GetFirst()
    return s.tpfil(c,tp)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local desc=eg:GetFirst():GetBattledGroup()
    local atk=desc:GetFirst()
    local tpdam=(atk:GetBaseAttack())/2
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(tpdam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tpdam)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.cfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
    and c:IsRace(RACE_FAIRY) end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.cfilter),c:GetControler(),LOCATION_PZONE,0,1,nil)
end
function s.datkfil1(c,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
    and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
function s.datkt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsCanBeEffectTarget(e) and chkc:IsControler(tp)
    and chkc:IsLocation(LOCATION_MZONE) and s.datkfil1(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.datkfil1,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.datkfil1,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(1500)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
function s.datkfil2(c,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7)
        and c:IsControler(tp) and c:IsFaceup()
end
function s.datkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    --Changed variable within CreateEffect from e:GetHandler (which doesn't make sense to me) to tc
    local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
    if Duel.IsExistingMatchingCard(s.datkfil2,tp,LOCATION_MZONE,0,1,nil,tp) then
        Duel.BreakEffect()
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        Duel.Damage(p,d,REASON_EFFECT)
    end
end