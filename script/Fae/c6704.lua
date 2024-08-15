--Oberon, Mors King of the Fae
--Scripted by Nerfvous
local s,id = GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    --Special Summon from hand
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcond)
    c:RegisterEffect(e1)
    --Add "Fae" quick-spell
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.athc)
    e2:SetOperation(s.athop)
    c:RegisterEffect(e2)
    --Destroy
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e3:SetHintTiming(TIMING_BATTLE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.descon)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end
s.listed_series={0x29e}
s.counter_place_list={0x1500}
--Facedown filter
function s.fdfil(c)
    return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
--Special Summon condition
function s.spcond(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetMatchingGroupCount(s.fdfil,tp,LOCATION_MZONE,0,nil)>1
end
--Fae filter
function s.faefil(c)
    return c:IsSetCard(0x29e) and c:IsAbleToHand() and c:IsType(TYPE_QUICKPLAY)
end
--AC Quick-play Fae
function s.athc(e,tp,eg,ep,ev,re,r,rp,chk)
    local fdg=Duel.GetMatchingGroupCount(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEDOWN_DEFENSE)
    if chk==0 then return fdg>0 and Duel.IsExistingMatchingCard(s.faefil,tp,LOCATION_DECK,0,fdg,nil)
        and Duel.IsPlayerCanDraw(tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,fdg,tp,LOCATION_DECK)
end
--Add to hand
function s.athop(e,tp,eg,ep,ev,re,r,rp)
    local fdg=Duel.GetMatchingGroupCount(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEDOWN_DEFENSE)
    local g=Duel.GetMatchingGroup(s.faefil,tp,LOCATION_DECK,0,nil)
    if #g<fdg then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tg=g:Select(tp,fdg,fdg,nil)
    Duel.SendtoHand(tg,tp,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,tg)
    Duel.ShuffleHand(tp)
    Duel.ShuffleDeck(tp)
end
--Filter for monsters with Mors counters
function s.morsfilter(c)
    return c:IsMonster() and c:HasCounter(0x1500)
end
--Check for monsters with Mors counters
function s.descon(c,tp)
    return Duel.GetCurrentPhase()==PHASE_BATTLE
    and Duel.IsExistingMatchingCard(s.morsfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.morsfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end