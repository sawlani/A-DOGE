
function addNoise(A)

 %[B1, B2] =
load('raw_MATLAB_Nov_2010/RC97.mat')


cnt = 100;
for c=1:cnt
    
     B1 = A;
     B2 = A;
     
     %indices = randi([1 41],2,1);
     indices = randi([1 41]);
%      while(indices(1)==indices(2))
%          indices = randi([1 41],2,1);
%      end
    % indices
    
nxt = 1;   
cumn = 0;
for i=1:41
    
    if(nxt > length(indices))
           continue;
    end
    
    M = RC97.SA{i};
       
    n = size(M,1);  
    
    if(i == indices(nxt))
       nxt = nxt + 1;
        
 
    
       p = RC97.SP{i};
       indparty1 = find(p==100);
       indparty2 = find(p==200);
       partyind = [indparty1;indparty2];
 %      otherind = setdiff(1:length(p), partyind);
    
      lenparty1 = length(indparty1);
      lenparty2 = length(indparty2);
    
      
      %minimum and %mean
      a=0.01; b=0.05;
      
       %simulate option 1
    %if(opt == 1)
        
       randpartyind = partyind(randperm(length(partyind))) + cumn;
        
        
        noise = a + (b-a) * rand(lenparty1,lenparty1);
        noise = noise + noise';
        
        %extra = sum(sum(noise));
        
        strt = cumn+1;
        endd = cumn+lenparty1;
        B1(strt:endd,strt:endd) = B1(strt:endd,strt:endd) + noise;
%        sum(sum(B1(strt:endd,strt:endd)))
        p1 = randpartyind(1:lenparty1);
        B2(p1, p1) = B2(p1,p1) + noise;
%sum(sum(B2(strt:endd,strt:endd)))
%pause
        
        noise = a + (b-a) * rand(lenparty2,lenparty2);
        noise = noise + noise';
        
        %extra = extra + sum(sum(noise));
        
        strt = cumn+lenparty1+1;
        endd = cumn+lenparty1+lenparty2;
       B1(strt:endd,strt:endd) = B1(strt:endd,strt:endd) + noise;
        
 %        sum(sum(B1(strt:endd,strt:endd)))
         
        p2 = randpartyind(lenparty1+1:end);
        B2(p2, p2) = B2(p2,p2) + noise;
%        sum(sum(B2(strt:endd,strt:endd)))
%pause
   % else
   %simulate option 2
        
        
%         noise = a + (b-a) * rand(n,n)/2;
%         noise = noise + noise';
%         
%         delta = (sum(sum(noise)) - extra) / n^2;
%         noise = noise - delta;
%         
%         strt = cumn+1;
%         endd = cumn+n;
%         B2(strt:endd,strt:endd) = B2(strt:endd,strt:endd) + noise;
       
   % end
    

    
    
    end
    
    cumn = cumn+n;
 

end

sum(sum(B1))
sum(sum(B2))
% figure; spy(B1)
 figure; colormap('hot'); imagesc((B1)); colorbar; set(gca,'FontSize',18)
 saveas(gcf,strcat('congress-sim3/within/spy-',num2str(c),'.jpg'))
% figure; spy(B2)
 figure; colormap('hot'); imagesc((B2)); colorbar; set(gca,'FontSize',18)
 saveas(gcf,strcat('congress-sim3/random/spy-',num2str(c),'.jpg'))

% pause
 
%   if(opt==1)
     save(strcat('congress-sim3/within/B1-',num2str(c),'.mat'), 'B1')
%  else
     save(strcat('congress-sim3/random/B2-',num2str(c),'.mat'), 'B2')
%  end
 

end



end