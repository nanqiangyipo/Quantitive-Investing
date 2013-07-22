function TradingStyles(symbol,startvec,endvec,Money,bRate,sRate,n)
%% ==================* Quantitive-Investing *==============================
%      https://github.com/zihaolucky/Quantitive-Investing
%
%% Instructions
% symbol - symbol of the stock
% startvec,endevc - begin and end date as a vector
% bRate - when the price is lower bRate percent of the cost

%% Data Import and Regularization.

fprintf('Downloading Historical Data...\n\n')
[Open,High,Low,Close,items]=getData(symbol,startvec,endvec,cd);


%% Initialize Variables.

% initial price, usable money
p0=Open(1);
MoneyFree=Money-p0*n*100*1.005;
% capital
Capital=Close(1)*n*100+MoneyFree;
capital=[Capital];
% value
Value=Close(1)*100;
% cost/share
S_cost=p0*1.005;

% a vecot contains the buy & sell
pBuy=[p0];
pSell=[];

% sell, bug day
sDay=[];  
bDay=[1];

% total profit, profit/day
T_profit=0;
profit=zeros(1,items); 


%%
fprintf('The initial price is %2.2f.... Press enter to continue.\n\n',p0);
pause;


for i=2:items

    fprintf('---- Day %d ----\n',i)
    fprintf('Stocks: %d\n',n*size(pBuy,2))
    fprintf('MoneyFree: %2.2f\n\n',MoneyFree)
    
    % when we don't have any stocks
    if size(pBuy,2)==0 && MoneyFree>Open(i)*n*100*1.005
        pBuy=Open(i);
        fprintf('Trading again !\n')
        fprintf('    Buy!\n')
        fprintf('Price: %2.2f\n',pBuy(end))
        MoneyFree=MoneyFree-pBuy(end)*n*100*1.005;
        bDay=[bDay,i];
        S_cost=mean(pBuy);
    end
    
    % we have stocks
    if size(pBuy)>0
        if pBuy(end)*(1-bRate)>Low(i) && MoneyFree>pBuy(end)*(1-bRate)*n*100*1.005
            pBuy=[pBuy,pBuy(end)*(1-bRate)];
            fprintf('    Buy!\n')
            fprintf('Price: %2.2f\n',pBuy(end))
            MoneyFree=MoneyFree-pBuy(end)*n*100*1.005;
            bDay=[bDay,i];
            S_cost=mean(pBuy);
        end
        if pBuy(end)*(1+sRate)<High(i) && Low(i)<pBuy(end)*(1+sRate)
            profit(i)=pBuy(end)*sRate*n*100*0.995;
            sDay=[sDay,i];
            fprintf('    Sell!\n')
            fprintf('Price: %2.2f\n\n',pBuy(end)*(1+sRate))
            MoneyFree=MoneyFree+(pBuy(end)*(1+sRate))*n*100*0.995;
            pBuy=[pBuy(1:end-1)];
            S_cost=mean(pBuy);
        end
    end
    
    Value=(Close(i)*n*size(pBuy,2)*100);
    Capital=Value+MoneyFree;
    
    T_profit=T_profit+profit(i);
    capital=[capital Capital];
    % fprintf('Cost/share: %2.2f \n',costing)
    % fprintf('Today`s profit: %2.2f \n',profit(i))
    fprintf('Total profit: %2.2f \n',T_profit)
    fprintf('Value : %2.2f \n',Value)
    fprintf('Capital: %2.2f \n',Capital)
    
    fprintf('Stocks left: %d \n\n',n*size(pBuy,2))
end

fprintf('Trading end... \n\n')
fprintf('Finally, the Value of our stocks are %2.2f yuan.\n',Value)
fprintf('Finally, our Total profit is %2.2f yuan.\n',T_profit)
fprintf('Finally, our Total Capital is %2.2f yuan.\n',Capital)

%% Visualize the flatuation of price and profit

figure(1);
subplot(2,1,1);
plot(1:items,Close,'linewidth',1.5,'color','r')
title({symbol},'FontSize',12)
s_date=[num2str(startvec(1)) '-' num2str(startvec(2)) '-' num2str(startvec(3))];
ylabel('Close Price','FontSize',12)

subplot(2,1,2);
N=fix(Money/(Open(1)*100));
Moneyfree=Money-N*Open(1)*100;
plot(1:items,capital,'linewidth',1.3,'color','b')
hold on
plot(1:items,Close*100*N+Moneyfree,'linewidth',1.3,'color','r')
title('Comparison','FontSize',12)
xlabel({'Start from',s_date},'FontSize',12)
ylabel('Capital','FontSize',12)
legend('With Stretegy','Normal Style')




        