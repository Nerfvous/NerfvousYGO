--Tea Party Triumvate - Mika
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
    e1:SetCode(EVENT_FREE_CHAIN) --EVENT_FREE_CHAIN refers to an open gamestate where no effects are activating. This also allows for the effect to be activated during a chain.
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET) --SetProperty changes the property of the effect. EFFECT_FLAG_CARD_TARGET makes it so that the effect only affects face-up cards
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id) --Limits the amount of times the effect can be triggered per turn which in this case is hard 1-ce per turn heheh
    e1:SetCondition(Duel.IsMainPhase)
	e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    --Light pendulum monsters whose original atk is 1500 atk or less attacks directly
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.gfilter)
	c:RegisterEffect(e2)
    --Place 1 "Tea Party" Trap from deck face-up to spell/trap zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.trapt)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.trapop)
    c:RegisterEffect(e3)
    --This card's ATK increases for every monster opponent controls by 500 atk each
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.atkcond)
    e4:SetValue(s.atkup)
    c:RegisterEffect(e4)
    --Direct attack
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_DIRECT_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.atkcond)
    c:RegisterEffect(e5)
    --Place 1 card on the field or GY to the top of the owner's deck
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_TODECK)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_BATTLE_DAMAGE)
    e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.targetplcond)
    e6:SetOperation(s.targetplop)
    c:RegisterEffect(e6)
end
s.listed_series={0x294}
s.listed_name={id}
function s.cfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsMainPhase()
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
    if not (tc:IsRelateToEffect(e) and tc:IsInMainMZone(tp) and Duel.CheckPendulumZones(tp)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    --Duel.SpecialSummon(tc,nil,tp,tp,true,true,POS_FACEUP)
	Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.gfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetBaseAttack()<=1500
end
function s.trapfil(c,tp)
    return c:IsSetCard(0x294) and c:IsTrap() and not c:IsForbidden()
end
function s.trapt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.trapfil,tp,LOCATION_DECK,0,1,nil,tp)
    end
end
function s.trapop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.trapfil),tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end    
function s.atkcond(e,c)
	return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)
	<Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandler():GetControler(),0,LOCATION_MZONE,nil)
end
function s.atkup(e)
    return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandler():GetControler(),0,LOCATION_MZONE,nil)*500
end
function s.targetfil(c)
    return c:IsAbleToDeck()
end
function s.targetplcond(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttacker():IsControler(tp) and Duel.GetAttackTarget()==nil
end
function s.targetplop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.targetfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=g:Select(tp,1,1,nil)
        Duel.BreakEffect()
        Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
    end
end