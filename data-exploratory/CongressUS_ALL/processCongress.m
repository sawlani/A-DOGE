function processCongress(opt, c)

load('raw_MATLAB_Nov_2010/RC97.mat')



allnames = {};
for i=1:41
    i
   % pause
   
    
    n=RC97.Sstring{i};
    names = {};
    for j=1:size(n,1)
        %j
        C = strsplit(n(j,:));
        
        if(isempty(char(C(end))))
            C = C(1:end-1);
        end
        
        if(length(char(C(1))) >= 3) %% problem
            ix = 2;     
        else
            
            ix = 3; 
        end
        
        if(length(char(C(ix+1))) < 4)
            %%%% firstind = 5;
            if(length(C)>=ix+3)
               % strcat(C(ix+2), C(ix+3))
                names(j) = strcat(C(ix+2), C(ix+3));
            else
               % C(ix+2)
                names(j) = C(ix+2);
            end
            
        else
            %%% firstind = 4;
            if(length(C)>=ix+2)
               % strcat(C(ix+1), C(ix+2))
                names(j) = strcat(C(ix+1), C(ix+2));
            else
              %  C(ix+1)
                names(j) = C(ix+1);
            end
        end
    
    end
    
    
    allnames = [allnames names];
        
end



totaln = size(allnames,2)

A = zeros(totaln,totaln);
labels = ones(totaln,1)*3;

cumn = 0;

party1indices = [];
party2indices = [];

for i=1:41

    M = RC97.SA{i};
    B=M;

%    B(B<0.75)=0;
%    clear M;
    
    n = size(B,1);
    
    p = RC97.SP{i};
    indparty1 = find(p==100);
    indparty2 = find(p==200);
    partyind = [indparty1;indparty2];
    otherind = setdiff(1:length(p), partyind);
    reorder = [partyind; otherind'];
    
    lenparty1 = length(indparty1);
    lenparty2 = length(indparty2);
    
%     if(opt == 1)
%         a=1.5; b=4;
%         mltp = a + (b-a) * rand;
%         noise = rand(lenparty1,lenparty2) * mltp;
%     else
%         a=0.3; b=0.7;
%         mltp = a + (b-a) * rand;
%         noise = rand(lenparty1,lenparty2) * mltp;
%     end
%     
%     B(indparty1, indparty2) = B(indparty1, indparty2)+noise;
%     B(indparty2, indparty1) = B(indparty2, indparty1)+noise';
% 
    %     
%    spy(B(reorder,reorder))
%    pause
%     s=length(p);

    %A(cumn+1:cumn+n,cumn+1:cumn+n) = B;
    A(cumn+1:cumn+n,cumn+1:cumn+n) = B(reorder,reorder);
    
    party1indices = [party1indices; ((cumn+1):(cumn+length(indparty1)))'];
    party2indices = [party2indices; ((cumn+length(indparty1)+1):(cumn+length(partyind)))'];
    
    
    
    clear B;
    
    cumn = cumn+n;
 

end

%labels(party1indices)=1;
%labels(party2indices)=2;



 spy(A)
 figure; colormap('hot'); imagesc((A)); colorbar; set(gca,'FontSize',18)



val = 0.1;
for i=1:totaln
    
    
    i
    
    %if((i+totaln/2) > totaln)
   %     endpt = totaln;
    %else
    %    endpt = (i+totaln/2);
    %end
    
    
    %exact_match_mask = strcmp(allnames(i:endpt),allnames(i));
    %exact_match_locations = find(exact_match_mask)+i;
    exact_match_mask = strcmp(allnames,allnames(i));
    exact_match_locations = find(exact_match_mask);
    exact_match_locations = setdiff(exact_match_locations, 1:i);
    if(isempty(exact_match_locations))
        continue;
    end
    

    
    diff = exact_match_locations - [i exact_match_locations(1:end-1)];
    
    
    ixx=find(diff>200);
    if(~isempty(ixx))
       % exact_match_locations
        exact_match_locations = exact_match_locations(1:ixx(1)-1);
        %exact_match_locations
     %pause
    end
    %val = 0.5*exp(-val*abs(exact_match_locations-i));
    
    if(isempty(exact_match_locations))
        continue;
    end
    
   % pause
    A(i,exact_match_locations) = val;
    A(exact_match_locations,i) = val;
    
end

 spy(A)
  figure; colormap('hot'); imagesc((A)); colorbar; set(gca,'FontSize',18)

 
 if(opt==1)
    save(strcat('congress-sim/more/A',num2str(c),'.mat'), 'A')
 else
    save(strcat('congress-sim/less/A',num2str(c),'.mat'), 'A')
 end
 

% B=A+eye(totaln);
% %B(B<0.001)=0;
% %spy(B)
% 
% 
% 
% D=diag(1./sqrt(sum(B,1))); Bn=D*B*D; [V,E] = eig(Bn);






%e=diag(E);

%[se sind] = sort(e,'descend');


%V = V(:,sind);



% max(diag(E))
% min(diag(E))
% hist(diag(E),50)
% 
% 
% tope = se(1:100);
% 
% bar(tope.^2 / sum(se.^2))

% for i=1:65
%     figure; hold on;
%     plot(1:totaln, V(:,i),'g.','Markersize',13)
%     plot(party1indices, V(party1indices,i),'r.','Markersize',13)
%     plot(party2indices, V(party2indices,i),'b.','Markersize',13)
% end
% 
% ipr=zeros(totaln,1);
% for i=1:totaln
%    ipr(i) = sum( V(:,i).^4 );
% end
%     
% [sipr, ind] = sort(ipr,'descend');
% 
% sipr(1:30)
% ind(1:30)
% 
% 
% for i=76:150
% figure; hold on;
% plot(1:totaln, V(:,ind(i)),'g.','Markersize',13)
% plot(party1indices, V(party1indices,ind(i)),'r.','Markersize',13)
% plot(party2indices, V(party2indices,ind(i)),'b.','Markersize',13)
% pause
% end

end 









