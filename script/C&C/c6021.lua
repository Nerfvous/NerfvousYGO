--The Professional C&C Club
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Normal summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,{id,0})
    e2:SetRange(LOCATION_SZONE)
    e2:SetTarget(s.nstg)
    e2:SetOperation(s.nsop)
    c:RegisterEffect(e2)
    --Move to different zone
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.movecon)
    e3:SetTarget(s.movetg)
    e3:SetOperation(s.moveop)
    c:RegisterEffect(e3)
    --Place to bottom of deck
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetHintTiming(0,TIMING_END_PHASE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(s.tdcon)
    e4:SetTarget(s.tdtg)
    e4:SetOperation(s.tdop)
    c:RegisterEffect(e4)
end
function s.nsfil(c)
    return c:IsSetCard(0x258) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.nsfil,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.nsfil,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
    Duel.Summon(tp,tc,true,nil)
end
function s.movefil(c,tp)
    return c:IsLink(1) and c:IsControler(tp)
end
function s.movecon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.movefil,1,nil,tp)
end
function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsLinkMonster() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsLinkMonster,tp,LOCATION_MZONE,0,1,nil)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,Card.IsLinkMonster,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    Duel.SetOperationInfo(0,0,tc,1,0,0)
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local count,zone=Duel.GetMZoneCount(tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and count>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local tz=math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,zone, check),2)
        Duel.MoveSequence(tc,tz)
    end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_END
end
function s.tdfil1(c,tp)
    return c:IsAbleToDeck() and Duel.IsExistingTarget(s.tdfil2,tp,LOCATION_GRAVE,0,1,nil,c)
end
function s.tdfil2(c)
    return c:IsSetCard(0x258) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.tdfil(chkc,e) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
    if chk==0 then return Duel.IsExistingTarget(s.tdfil1,tp,LOCATION_GRAVE,0,2,nil,tp) end
    local g=Duel.GetMatchingGroup(s.tdfil1,tp,LOCATION_GRAVE,0,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg1=g:FilterSelect(tp,s.tdfil2,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg2=g:Select(tp,1,1,sg1:GetFirst())
    sg1:Merge(sg2)
    Duel.SetTargetCard(sg1)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,sg1,2,tp,LOCATION_DECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
    if tg then
        Duel.SendtoDeck(tg,tp,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
end