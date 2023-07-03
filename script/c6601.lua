--Tea Party Triumvirate - Nagisa
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
    --Light monsters you control cannot be targeted by Spell/Trap or effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTarget(s.etarget)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetValue(s.evalue)
    c:RegisterEffect(e2)
    --Place 1 "Tea Party" spell from deck to field face-up
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.spellt)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.spellop)
    c:RegisterEffect(e3)
    --Return opp's cards up to number of LIGHT monsters on your field
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,{id,2})
    e4:SetTarget(s.gtarget)
    e4:SetRange(LOCATION_MZONE)
    e4:SetOperation(s.gop)
    c:RegisterEffect(e4)
    --Becomes quick effect
    local e5=e4:Clone()
    e5:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetCondition(function(_,tp) return Duel.HasFlagEffect(tp,id) end)
    c:RegisterEffect(e5)
    --Checks if a Light monster(s) was special summoned to the field
    aux.GlobalCheck(s,function()
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_SPSUMMON_SUCCESS|EVENT_SUMMON_SUCCESS)
    ge1:SetOperation(s.checkop)
    Duel.RegisterEffect(ge1,0)
end)
end
s.listed_series={0x294}
function s.cfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
end
function s.etarget(e,c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER)
end
function s.evalue(e,re,rp,tp)
    return aux.tgoval(e, re:IsActiveType(TYPE_SPELL+TYPE_TRAP), rp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end --checks if the targeted card is in the main zone, the triggering player's and is a light pendulum
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 --checks for available space in mainzone, in this case more than 0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) --false, false instead?
        and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
        --filter/card object, which player to check, from which location to check, minimum card for activation, maximum card for activation, exceptions;use nil if there aren't
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
function s.spellfil(c,tp)
    return c:IsSetCard(0x294) and c:IsSpell() and not c:IsForbidden()
end
function s.spellt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.spellfil,tp,LOCATION_DECK,0,1,nil,tp)
    end
end
function s.spellop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.spellfil,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if tc and tc:IsType(TYPE_FIELD) then
        local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
        if fc then
            Duel.SendtoGrave(fc,REASON_EFFECT)
            Duel.BreakEffect()
        end
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    else
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
function s.gfilter(c)
    return c:IsAbleToHand()
end
function s.gfilter2(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsOriginalType(TYPE_MONSTER)
end
function s.gtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE)
    and s.gfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.gfilter,tp,0,LOCATION_MZONE,1,nil)
        and Duel.IsPlayerCanSendtoHand(1-tp)
        and Duel.IsExistingMatchingCard(s.gfilter2,tp,LOCATION_ONFIELD,0,1,nil)
    end
    local gt=Duel.GetMatchingGroupCount(s.gfilter2,tp,LOCATION_ONFIELD,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.gfilter,tp,0,LOCATION_MZONE,1,gt,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    Duel.SendtoHand(g,1-tp,REASON_RETURN)
end
function s.cfilter2(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
    and c:IsReason(REASON_SPSUMMON+REASON_SUMMON)
end
--Checks if any groups of card matching s.cfilter2 exists excluding itself (e:GetHandler())
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.cfilter2,e:GetHandler())
    for tc in g:Iter() do
        Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
    end
end