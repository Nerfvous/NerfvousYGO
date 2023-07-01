--Tea Party - School of Trinity
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Add 1 "Tea Party" face-up monster from extra deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetOperation(s.xtrop)
    c:RegisterEffect(e1)
    --When placed faceup
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_MOVE)
    e2:SetTarget(s.xtrtg)
    e2:SetCondition(s.xtrcon)
    c:RegisterEffect(e2)
    --Attacks highest atk
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.atklimcon)
    e3:SetValue(s.atklimit)
    c:RegisterEffect(e3)
    --Each Light Pendulum monster get protected once, each turn
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.indcon)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x294))
	e4:SetValue(s.indct)
	c:RegisterEffect(e4)
    --Unaffected except when targeted
	local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,4))
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(s.immcon)
    e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x294))
	e5:SetValue(s.immval)
	c:RegisterEffect(e5)
    --Return to deck during End Phase
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,5))
    e6:SetCategory(CATEGORY_TODECK)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetRange(LOCATION_SZONE)
    --e6:SetCountLimit(1,{id,5})
    e6:SetCode(EVENT_PHASE+PHASE_END)
    e6:SetTarget(s.tgtg)
    e6:SetOperation(s.tgop)
    c:RegisterEffect(e6)
end
s.listed_series={0x294}
function s.xtrfil(c)
    return c:IsSetCard(0x294) and c:IsMonster()
        and c:IsFaceup() and c:IsAbleToHand()
end
function s.sndfil(c)
    return c:IsType(TYPE_MONSTER+TYPE_PENDULUM) and c:IsAbleToExtra()
end
--This is needed so that the effect will not trigger if no faceup Light Pendulum monsters are in the ED
function s.xtrtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.xtrfil,tp,LOCATION_EXTRA,0,1,nil,tp)
    and Duel.IsPlayerCanSendtoHand(tp)
    end
end
function s.xtrop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.xtrfil,tp,LOCATION_EXTRA,0,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    if #g<1 or Duel.SelectYesNo(tp,aux.Stringid(id,0))==false or not Duel.IsPlayerCanSendtoHand(tp)
        or Duel.SendtoHand(g:Select(tp,1,1,nil,tp),tp,REASON_EFFECT,nil,tp)<1  then
    return end
    Duel.ConfirmCards(1-tp,g)
    if Duel.IsExistingMatchingCard(s.sndfil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        local ct=Duel.SelectMatchingCard(tp,s.sndfil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
        Duel.SendtoExtraP(ct,tp,REASON_EFFECT)
    end
end
function s.xtrcon(e)
    local c=e:GetHandler()
    Debug.Message(c:IsReason(REASON_EFFECT))
    return c:IsLocation(LOCATION_FZONE) and c:IsFaceup()
end
function s.atklimfil(c,tp)
    return c:IsMonster() and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.atklimcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroupCount(aux.FaceupFilter(s.atklimfil),tp,LOCATION_ONFIELD,0,nil)
    --Debug.Message(g)
    return g>=2
end
function s.atklimit(e,c)
    local tp=c:GetControler()
    local atk=Duel.GetMatchingGroup(s.atklimfil,tp,LOCATION_MZONE,0,nil,tp):GetMaxGroup(Card.GetAttack):GetFirst()
    --Debug.Message(atk)
    return c:GetAttack()<atk:GetAttack()
end
function s.indcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroupCount(aux.FaceupFilter(s.atklimfil),tp,LOCATION_ONFIELD,0,nil)
    --Debug.Message(g)
    return g>=4
end
--Checks if the an event happening to a card is because of battle or effect
function s.indct(e,re,r,rp)
	if ((r&REASON_EFFECT==REASON_EFFECT) or (r&REASON_BATTLE==REASON_BATTLE)) then
		return 1
	else return 0 end
end
function s.immcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroupCount(aux.FaceupFilter(s.atklimfil),tp,LOCATION_ONFIELD,0,nil)
    --Debug.Message(g)
    return g>=6
end
--Checks if the effect is a monster effect and targets
function s.immval(e,te,re)
    local c=te:GetHandler()
	if not c:IsType(TYPE_MONSTER) or e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
end