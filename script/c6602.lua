--Tea Party Triumvirate - Seia
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c)
    --Special Summon this card and place a targeted Light Pendulum face-up monster you control in your Pendulum Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN) 
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(Duel.IsMainPhase)
	e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    --Light monster effects cannot be negated
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTarget(s.tg)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetValue(s.gnegate)
    c:RegisterEffect(e2)
    --Excavate 5 cards
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetTarget(s.exctg)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetOperation(s.excop)
    --e3:SetCondition(s.excond)
    c:RegisterEffect(e3)
    --Place to deck top
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	--e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
    e4:SetCost(s.discost)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
s.listed_series={0x294}
function s.tg(e,c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
function s.cfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
end
function s.gnegate(e,te,tp)
	local c=te:GetHandler()
	return c:IsType(TYPE_MONSTER)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
        and s.cfilter(chkc) end
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) and not Duel.CheckPendulumZones(tp) then return end
    Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4
        and Duel.IsPlayerCanSendtoHand(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.excfilter(c,e,tp)
	return c:IsSetCard(0x294) and c:IsAbleToHand()
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 
        or not Duel.IsPlayerCanSendtoHand(tp) then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5):Filter(s.excfilter,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
        g:RemoveCard(tc)
        Duel.DisableShuffleCheck()
    end
    Duel.MoveToDeckBottom(g,tp)
    Duel.SortDeckbottom(tp,tp,#g)
end
function s.disfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sc=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,0,1,1,nil)
    Duel.SendtoDeck(sc,tp,SEQ_DECKTOP,REASON_COST)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and rp~=tp
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local rc=re:GetHandler()
    Duel.SetTargetCard(rc)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,rc,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local rc=Duel.GetTargetCards(e)
    Debug.Message(rc)
    if #rc<=0 then return end
    Debug.Message(#rc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    Duel.SendtoDeck(rc,1-tp,SEQ_DECKTOP,REASON_EFFECT)
end
function s.excond(e,eg)
    return eg==e:GetHandler()
end
