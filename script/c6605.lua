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
	--e4:SetCountLimit(1,{id,1})
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
    --Debug.Message(hatk)
    local atkval=hatk:GetAttack()
    --Debug.Message(atkval)
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
        and (c:IsReason(REASON_SPSUMMON) or c:GetReason()==0)
end
function s.tpfil(c,tp)
    return c:IsControler(tp) and c:IsStatus(STATUS_OPPO_BATTLE)
    and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
    and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
--[[ function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
    if not d then return false end
    if d:IsControler(tp) then a,d=d,a
    end
    Debug.Message(eg:GetFirst())
    local atk=eg:IsExists(s.dmgfil,1,nil,1-tp)
    --local atk=Duel.GetMatchingGroup(s.dmgfil,tp,0,LOCATION_GRAVE,nil):GetFirst()
    --Debug.Message(atk)
    --Debug.Message(a:IsAttribute(ATTRIBUTE_LIGHT))
    return atk and a:IsAttribute(ATTRIBUTE_LIGHT)
end ]]
--[[ 
    --this is actually functional but the loop feels weird for me so I opted to filter the cards instead
    function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    if not eg then return end
    Debug.Message(eg:GetFirst())
    for rc in aux.Next(eg) do
        if rc:IsStatus(STATUS_OPPO_BATTLE) then
            if (rc:IsControler(tp) or rc:IsPreviousControler(tp)) and rc:IsAttribute(ATTRIBUTE_LIGHT)
            and rc:IsRelateToBattle() then
                return true end
            end
        end
    return false
end ]]
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=eg:GetFirst()
    return s.tpfil(c,tp)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    --[[ local desc=eg:Filter(Card.IsStatus(c,STATUS_BATTLE_DESTROYED),nil):GetFirst()
    local tpdam=(desc:GetAttack())/2 ]]
    --Debug.Message(Card.GetBattledGroup)
    --Debug.Message(eg:GetFirst():GetBattledGroup())
    local desc=eg:GetFirst():GetBattledGroup()
    local atk=desc:GetFirst()
    --local atk=eg:Filter(Card.IsControler(1-tp),nil)
    --Debug.Message(atk)
    local tpdam=(atk:GetBaseAttack())/2
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(tpdam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tpdam)
    --Duel.SetOperationInfo(chainc, category, targets, count, target_player, target_param)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    --Debug.Message(d)
	Duel.Damage(p,d,REASON_EFFECT)
end
--[[ 
    --does not work in the context of the effect taking place after the battle
    function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
    Debug.Message(a,d)
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
    Debug.Message(a:IsStatus(STATUS_BATTLE_DESTROYED))
    Debug.Message(d:IsStatus(STATUS_BATTLE_DESTROYED))
    Debug.Message(eg:GetFirst())
    --Debug.Message(Duel.GetBattleMonster(tp))
	return a:IsAttribute(ATTRIBUTE_LIGHT)
		and not a:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsStatus(STATUS_BATTLE_DESTROYED)
end ]]
function s.cfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
    and c:IsRace(RACE_FAIRY) end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.cfilter),c:GetControler(),LOCATION_PZONE,0,1,nil)
end
function s.datkfil1(c,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsControler(tp)
    and c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
function s.datkt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsCanBeEffectTarget(e) and s.datkfil1(chkc,tp)
        and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(s.datkfil1,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.datkfil1,tp,LOCATION_MZONE,0,1,1,nil,tp)
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
    if tc and tc:IsRelateToEffect(e) then
        --Changed variable within CreateEffect from e:GetHandler (which doesn't make sense to me)
            --to tc
        local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
    if Duel.IsExistingMatchingCard(s.datkfil2,tp,LOCATION_MZONE,0,1,nil,tp) then
        Duel.BreakEffect()
        local p,d=Duel.GetChainInfo(CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        Duel.Damage(p,d,REASON_EFFECT)
    end
end