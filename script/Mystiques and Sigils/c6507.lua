--Sigil of Mastery
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Gains LP
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.lpgcon)
    e2:SetOperation(s.lpgop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    --Special summon 1 Spellcaster with different attribute
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,0})
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.spt)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
    --Banish 1 "Sigil" from deck
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SEARCH+CATEGORY_REMOVE)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,{id,1})
    e5:SetCondition(s.bncon)
    e5:SetTarget(s.bnt)
    e5:SetOperation(s.bnop)
    c:RegisterEffect(e5)
end
s.listed_series={0x28c}
function s.lpgcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
end
function s.lpgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,200,REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.spcfil(c,e,tp)
    return c:IsLevelBelow(4) and c:IsRace(RACE_SPELLCASTER)
    and not c:IsForbidden() and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.spcfil1,e,c:GetAttribute()),tp,LOCATION_MZONE,0,1,nil)
end
function s.spcfil1(c,e,attrib)
    return not c:IsAttribute(attrib) and c:IsMonster()
end
function s.spt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return 
    Duel.IsExistingMatchingCard(s.spcfil,tp,LOCATION_HAND,0,1,nil,e,tp)
    and Duel.IsPlayerCanSpecialSummon(tp)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e)
    or not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,1,nil,e,tp)
    or not Duel.IsExistingMatchingCard(s.spcfil,tp,LOCATION_HAND,0,1,nil,e,tp)
    or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then
        return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spcfil,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
end
function s.bncon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
end
function s.bnfil(c,e)
    local tp=e:GetHandlerPlayer()
    return c:IsAbleToRemove() and c:IsSetCard(0x28c) and not c:IsMonster()
end
function s.bnt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanRemove(tp)
    and Duel.IsExistingMatchingCard(s.bnfil,tp,LOCATION_DECK,0,1,nil,e) end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_REMOVE,nil,1,tp,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.bnfil,tp,LOCATION_DECK,0,nil,e)
    if #g<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sc=g:Select(tp,1,1,nil)
    Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
end