--C&C 01: Asuna
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Special summon 1 Link monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.spsumtg1)
    e1:SetOperation(s.spsumop1)
    c:RegisterEffect(e1)
    --Excavate
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.excon)
    e3:SetTarget(s.exctg)
    e3:SetOperation(s.excop)
    c:RegisterEffect(e3)
end
s.listed_series={0x258}
--Checks if opp's turn and is main phase
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp and Duel.IsMainPhase()
end
function s.lsfilter(c,e)
    return c:IsSetCard(0x258) and c:IsLinkSummonable(e:GetHandler())
end
--Checks if there are any link monsters that can be Link Summon
function s.spsumtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lsfilter,tp,LOCATION_EXTRA,0,1,nil,e) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
--Link summon operation
function s.spsumop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
    local g=Duel.GetMatchingGroup(s.lsfilter,tp,LOCATION_EXTRA,0,nil,e)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.LinkSummon(tp,sg:GetFirst(),c)
    end
end
function s.lkfilter(c,tp)
    return c:IsLinkMonster() and c:IsControler(tp)
end
function s.excon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    return re:GetHandler():IsSetCard(0x258)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
    --needs to check if there is link monster in the field too
    local g=Duel.GetMatchingGroupCount(s.lkfilter,tp,LOCATION_MZONE,0,nil,tp)
    if chk==0 then return g>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>g end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
    local count=Duel.GetMatchingGroupCount(s.lkfilter,tp,LOCATION_MZONE,0,nil,tp)
    if count>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>count then
        Duel.ConfirmDecktop(tp,count)
        local g=Duel.GetDecktopGroup(tp,count)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        g:RemoveCard(tc)
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
        Duel.ConfirmCards(tp,tc)
        if #g>0 then
            Duel.SendtoDeck(g,tp,SEQ_DECKBOTTOM,REASON_EFFECT)
            Duel.SortDeckbottom(tp,tp,#g)
        end
    end
end