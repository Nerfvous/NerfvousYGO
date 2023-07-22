--Ascended Mystique Ayumi
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Link summon with at least 1 "Mystique" monster
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,3,s.lnmats)
    --Special summon by banishing
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spbcon)
	e1:SetTarget(s.spbt)
	e1:SetOperation(s.spbop)
	c:RegisterEffect(e1)
    --Special summon other "Mystique" monsters from deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.spt)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2,false,REGISTER_FLAG_TELLAR)
    --Shuffle 2 banished "Sigil"
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(1,2))
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.stdcost)
    e3:SetTarget(s.stdt)
    e3:SetOperation(s.stdop)
    c:RegisterEffect(e3)
end
s.listed_series={0x28a}
function s.lnmats(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,0x28a,lc,sumtype,tp)
end
function s.spbfil(c)
    return c:IsAbleToRemoveAsCost() and ((c:IsSetCard(0x28c)
     and c:IsLocation(LOCATION_SZONE+LOCATION_GRAVE)) or c:IsCode(6501) and c:IsLocation(LOCATION_MZONE))
     and c:IsFaceup()
end
function s.rescon(sg,e,tp,mg)
    local lc=Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())
    local c1=sg:GetClassCount(Card.GetLocation)
    local c2=#sg
    if lc>0 then
        return c1==c2,c1~=c2 end
    return false
end
function s.spbcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spbfil),tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
    if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==#g
    or g:FilterCount(Card.IsLocation,nil,LOCATION_SZONE)==#g
    or g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==#g then return false end
    return aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.spbt(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spbfil),tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
    local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
    if #sg>0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end
function s.spbop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    c:SetMaterial(sg)
    sg:DeleteGroup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spfil(c)
    return c:IsSetCard(0x28a) and c:IsMonster()
end
function s.spt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x28c),tp,LOCATION_SZONE,0,1,nil)
    and Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local spc=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x28c),tp,LOCATION_SZONE,0,nil)
    local g=Duel.GetMatchingGroup(s.spfil,tp,LOCATION_DECK,0,nil)
    if lc<1 or spc<1 or #g<1 then return end
    local num=math.min(lc,spc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,num,nil)
    if Duel.SpecialSummon(sg,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)>0 then
        --Can only special summon spellcasters from ED
        Duel.BreakEffect()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_SPELLCASTER) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.stdfil1(c)
    return c:IsAbleToDeck() and c:IsSetCard(0x28c) and not c:IsMonster()
end
function s.stdfil2(c)
    return c:IsAbleToHand() and c:IsSetCard(0x28a) and not c:IsMonster()
end
function s.stdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return
    Duel.IsExistingMatchingCard(aux.FaceupFilter(s.stdfil1),tp,LOCATION_REMOVED,0,2,nil)  end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(s.stdfil1),tp,LOCATION_REMOVED,0,2,2,nil)
    Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.stdt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSendtoHand(tp)
    and Duel.IsExistingMatchingCard(s.stdfil2,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,0,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.stdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.stdfil2,tp,LOCATION_DECK,0,nil)
    if #g<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoHand(sg,tp,REASON_EFFECT)
end