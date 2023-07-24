--Ayumi, The Mystique
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Place a Sigil Spell/Trap to the field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCategory(CATEGORY_SEARCH)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.splt)
    e1:SetOperation(s.splop)
    c:RegisterEffect(e1)
    --Normal Summon or Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.spnscost)
    e2:SetCondition(s.spnscon)
    e2:SetTarget(s.spnst)
    e2:SetOperation(s.spsnop)
    c:RegisterEffect(e2)
end
s.listed_series={0x28a}
function s.spfil(c)
    return c:IsSetCard(0x28c)
end
function s.splt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_DECK,0,1,nil)
    and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end
function s.splop(e,tp,eg,ep,ev,re,r,rp) --fine tune it so that field spell is placed in the correct place
    local g=Duel.GetMatchingGroup(s.spfil,tp,LOCATION_DECK,0,nil)
    if #g<1 or Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if sc and sc:IsType(TYPE_FIELD) then
        local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
        if fc then
            Duel.SendtoGrave(fc,REASON_EFFECT)
            Duel.BreakEffect()
        end
            Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    else
        Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
function s.costfil(c)
    return s.spfil(c) and c:IsAbleToGraveAsCost()
end
function s.monfil(c,e,tp)
    return c:IsSetCard(0x28a) and c:IsLevelBelow(4)
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
    and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.monfil2,e,c:GetAttribute()),tp,LOCATION_MZONE,0,1,nil)
end
function s.monfil2(c,e,attrib)
    return not c:IsAttribute(attrib) and c:IsMonster()
end
function s.spnscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ct=0
        if Duel.IsPlayerCanSendtoGrave(tp)
        and Duel.IsExistingMatchingCard(s.costfil,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil)
        then ct=ct+1 end
        if Duel.IsPlayerCanSpecialSummon(tp)
        and Duel.IsExistingMatchingCard(s.monfil,tp,LOCATION_DECK,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then ct=ct+1 end
        e:SetLabel(ct)
        return ct~=0
    end
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfil,tp,LOCATION_HAND+LOCATION_SZONE,0,1,ct,nil)
    e:SetLabel(#g)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.spnscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsPlayerCanAdditionalSummon(tp)
end
function s.spnst(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSummon(tp) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,e:GetLabel())
end
function s.spnsmon(c)
    return c:IsLevelBelow(4) and c:IsSetCard(0x28a) and c:IsMonster()
end
function s.spsnop(e,tp,eg,ep,ev,re,r,rp)
    local p,lb=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if lb>=1 and Duel.IsPlayerCanAdditionalSummon(tp) then
    -- Can Normal Summon 1 LIGHT monster in addition to your Normal Summon/Set
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
    end
    --Special Summon 1 "Mystique" monster from the deck
    if lb>=2
    and Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_DECK,0,1,nil,Card.IsLevelBelow,4)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummon(tp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=Duel.SelectMatchingCard(tp,s.spnsmon,tp,LOCATION_DECK,0,1,1,nil)
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
    end
end