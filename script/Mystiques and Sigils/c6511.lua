--Mystique Spell: Spring of Life
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Activation
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Special summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.spt)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
    --Add to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_TOHAND+CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.plct)
    e3:SetOperation(s.plcop)
    c:RegisterEffect(e3)
    --
end
s.listed_series={0x28a}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsRace(RACE_SPELLCASTER)
end
function s.chainfilter(re,tp,cid)
    return not (re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsRace(RACE_SPELLCASTER))
end
function s.spfil(c,e,tp,zone)
    return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
    and not Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_MZONE,0, 1,nil,c:GetAttribute())
end
function s.spt(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=aux.GetMMZonesPointedTo(tp,nil,LOCATION_MZONE,0)&Duel.GetZoneWithLinkedCount(2,tp)
    if chk==0 then return
    zone>0
    and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,6512)
    and Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_DECK,0,1,nil,e,tp,zone)
    and Duel.IsPlayerCanSpecialSummon(tp) end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,0,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    --local zone=aux.GetMMZonesPointedTo(tp,nil,LOCATION_MZONE,0)
    local zone=aux.GetMMZonesPointedTo(tp,nil,LOCATION_MZONE,0)&Duel.GetZoneWithLinkedCount(2,tp)
    if zone<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfil,tp,LOCATION_DECK,0,1,1,nil,e,tp,zone)
    Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,0,false,false,POS_FACEUP,zone)
end
function s.cfilter(c)
    return c:IsAbleToHand() and c:IsAbleToDeck()
    and (c:IsSetCard(0x28a) or (c:IsSetCard(0x28c) and c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)))
end
function s.plct(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsCanBeEffectTarget(e)
    and chkc:IsFaceup() and s.cfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(s.cfilter),tp,LOCATION_GRAVE,0,1,nil)
    and Duel.IsPlayerCanSendtoHand(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sc=Duel.SelectTarget(tp,aux.FaceupFilter(s.cfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE+CATEGORY_TOHAND+CATEGORY_TODECK,sc,1,tp,LOCATION_GRAVE)
end
function s.plcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetTargetCards(e)
    if not c:IsRelateToEffect(e) and not g then return end
    g:Merge(c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    g:RemoveCard(sc)
    if Duel.SendtoHand(sc,tp,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.SendtoDeck(g,tp,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
end