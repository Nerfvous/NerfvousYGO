--Fae Sìthichean
--Scripted by Nerfvous
local s,id = GetID()
function s.initial_effect(c)
--Place 1 Mors Counter
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
    --Level becomes Level 1
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_LEVEL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetTarget(function(e,c) return c:HasCounter(0x1500) and c:IsLevelAbove(2) end)
    e2:SetValue(function(e,c) return c:Level(1) end)
    c:RegisterEffect(e2)
    --Special summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    --Add 1 "Fae" Spell
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e4:SetCountLimit(1,{id,2})
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.athc)
    e4:SetOperation(s.athop)
    c:RegisterEffect(e4)
end
s.listed_series={0x29e}
s.counter_place_list={0x1500}
--Activation check for placing counter
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1500,1) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1500,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1500,1)
end
--Counter placement operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        tc:AddCounter(0x1500,1) end
end
--Filter Fae spell cards
function s.cfilter(c)
    return c:IsSetCard(0x29e) and not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
--Checks for a Fae card in hand
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
end
--Check activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
--Fae spell filter
function s.athfil(c)
    return c:IsSetCard(0x29e) and c:IsAbleToHand() and c:IsType(TYPE_SPELL)
end
--AC Fae spell add to hand
function s.athc(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.athfil,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
--Fae spell to hand
function s.athop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tg=Duel.SelectMatchingCard(tp,s.athfil,tp,LOCATION_DECK,0,1,1,nil)
    if #tg>0 then
        Duel.SendtoHand(tg,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tg)
        Duel.BreakEffect()
        Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE)
    end
end