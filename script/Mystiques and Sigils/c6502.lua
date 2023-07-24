--Rita, The Mystique
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Place up to 2 "Sigils" faceup on field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.plct)
    e1:SetOperation(s.plcop)
    c:RegisterEffect(e1)
    --Excavate and perhaps draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_DRAW)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.xdcost)
    e2:SetCondition(s.xdcon)
    e2:SetTarget(s.xdt)
    e2:SetOperation(s.xdop)
    c:RegisterEffect(e2)
end
s.listed_series={0x28a}
function s.plcfil(c)
    return c:IsSetCard(0x28c) and not c:IsMonster()
end
function s.plct(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    and Duel.IsExistingMatchingCard(s.plcfil,tp,LOCATION_DECK,0,1,nil) end
end
function s.plcif(sg,e,tp,mg)
    if #sg>1 and not mg:IsExists(Card.IsType,1,nil,TYPE_FIELD)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then
        return true end
end
--idk how this worked but thank you timelord trap
function s.plchk(sg,e,tp,mg,c)
    local lc=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local c1=sg:GetClassCount(Card.GetCode)
    local c2=sg:GetClassCount(Card.GetType)
    local c3=#sg
    if lc<2 and mg:IsExists(Card.IsType,1,nil,TYPE_FIELD) then
        return c1==c3 and c2==c3,c1~=c3 or c2~=c3 end
    return c1==c3,c1~=c3
end
function s.plcop(e,tp,eg,ep,ev,re,r,rp)
    local lc=Duel.GetLocationCount(tp,LOCATION_SZONE+LOCATION_FZONE)
    if lc<1 then return end
    local cn=math.max(lc,1)
    local g=Duel.GetMatchingGroup(s.plcfil,tp,LOCATION_DECK,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.plchk,1,tp,HINTMSG_TOFIELD,nil,s.plcif)
    --Iterates over the group
    for sc in aux.Next(sg) do
        if sc:IsType(TYPE_FIELD) then
        local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
            if fc then
            Duel.SendtoGrave(fc,REASON_EFFECT)
            Duel.BreakEffect()
            end
            Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(e2,true)
        else
            Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,false)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(e2,true)
        end
    end
end
function s.costfil(c)
    return s.plcfil(c) and c:IsAbleToGraveAsCost()
end
--Sends up to 2 spell/trap to the GY
function s.xdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ct=0
        if Duel.IsPlayerCanSendtoGrave(tp)
        and Duel.IsExistingMatchingCard(s.costfil,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil)
        then ct=ct+1 end
        if Duel.IsPlayerCanDraw(tp) then ct=ct+1 end
        e:SetLabel(ct)
        return ct~=0
    end
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfil,tp,LOCATION_HAND+LOCATION_SZONE,0,1,ct,nil)
    e:SetLabel(#g)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.xdcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsPlayerCanSendtoHand(tp)
end
function s.xdt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,e:GetLabel())
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.xdfil(c,e,tp)
    return c:IsSetCard(0x28a) or c:IsSetCard(0x28c) and c:IsAbleToHand()
end
function s.xdop(e,tp,eg,ep,ev,re,r,rp)
    local p,lb=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if lb>=1 and Duel.GetFieldGroupCount(p,LOCATION_DECK,0)>=3 then
        --Excavate
        Duel.ConfirmDecktop(p,3)
        local g=Duel.GetDecktopGroup(p,3):Filter(s.xdfil,nil,e,tp)
        if #g>0 then
            local tc=g:Select(p,1,1,nil)
            g:RemoveCard(tc)
            Duel.SendtoHand(tc,p,REASON_EFFECT)
            Duel.ConfirmCards(p,tc)
            Duel.SendtoDeck(g,p,SEQ_DECKSHUFFLE,REASON_RULE)
        end
    end
    --Special Summon 1 "Mystique" monster from the deck
    if lb>=2 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
    and Duel.IsPlayerCanDraw(tp) then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end