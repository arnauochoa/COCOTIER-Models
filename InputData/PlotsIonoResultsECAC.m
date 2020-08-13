close all
station_ECAC = ['acor';'alac';'brst';'dent';'eusk';'elat';'flrs';'hers';...
    'hofn';'ieng';'kiru';'klop';'lamp';'lpal';'mall';'nico';'nyal';...
    'orid';'qaq1';'scor';'sfer';'tlse';'trds';'wsrt';'zeck';...
    'tuc2';'zwe2'];
% station_ECAC = 'acor';
el_bin = 0:5:90;
% for each station attributes a space ID as a function of the Pos
% 0 for Northern stations
% 1 for Nothern Ecac center
% 2 for ECAC center
% 3 for Southern ECAC center
% 4 for Southern stations
SpaceGroup = [2 3 1 1 1 4 3 1 ...
    0 2 0 1 4 4 3 4 0 ...
    3 0 0 4 2 0 1 2 ...
    4 1];
i=1;

%% Correction by the mean bias obtained at one station

Result_MeanMat = nan(size(station_ECAC,1),length(el_bin)-1);
Result_StdMat = nan(size(station_ECAC,1),length(el_bin)-1);
Result_SizeMat = nan(size(station_ECAC,1),length(el_bin)-1);
% Bias = nan(size(station_ECAC,1),2880*length(dlist),1);
for ind_station = 1:size(station_ECAC,1)
    station_ID = station_ECAC(ind_station,:);
    load([station_ID '_IONO_results_full2014.mat']);
    disp(['station ' num2str(ind_station) '/' num2str(size(station_ECAC,1))])

    % Error between UISD and smoothed STEC, averaged for all satellites
    Bias = nanmean(Total_Range_Edel(i,:,:)-Total_Range_PL_sm(i,:,:),3);

    % Repeat bias for each satellite -> Dim = 1, nSampYear, nSat -> ENT-INT bias
    Bias32 = repmat(Bias',1,32,1); Bias32 = reshape(Bias32,1,[],32);

    % Deg to rad and reshape matrix to vector
    a = 180*reshape(Total_Range_Az(i,:,:),1,[])/pi;
    b = 180*reshape(Total_Range_El(i,:,:),1,[])/pi;

    % Error between UISD and smoothed STEC for all sats, shaped as vector
    AA = reshape(Total_Range_Edel(i,:,:)-Total_Range_PL_sm(i,:,:),1,[]);
    % Difference between satellite's bias and average bias
    BB = reshape(Total_Range_Edel(i,:,:)-Total_Range_PL_sm(i,:,:)-Bias32,1,[]);

    % Deg to rad and reshape matrix to vector excluding period from day 260 to 262
    abis = 180*reshape(Total_Range_Az(i,[1:260*2880 (1+262*2880):end],:),1,[])/pi;
    bbis = 180*reshape(Total_Range_El(i,[1:260*2880 (1+262*2880):end],:),1,[])/pi;

    % Like AA but excluding period from day 260 to 262
    CC = reshape( Total_Range_Edel(i,[1:260*2880 (1+262*2880):end],:) -     ...
                    Total_Range_PL_sm(i,[1:260*2880 (1+262*2880):end],:),1,[] );
    % Like BB but excluding period from day 260 to 262
    DD = reshape( Total_Range_Edel(i,[1:260*2880 (1+262*2880):end],:) -     ...
                    Total_Range_PL_sm(i,[1:260*2880 (1+262*2880):end],:) -  ...
                    Bias32(1,[1:260*2880 (1+262*2880):end],:),1,[] );

    %Initializations
    AA_mean_v = nan(length(el_bin)-1,1);
    AA_std_v = nan(length(el_bin)-1,1);
    AA_size_v = nan(length(el_bin)-1,1);
    BB_mean_v = nan(length(el_bin)-1,1);
    BB_std_v = nan(length(el_bin)-1,1);
    BB_size_v = nan(length(el_bin)-1,1);
    CC_mean_v = nan(length(el_bin)-1,1);
    CC_std_v = nan(length(el_bin)-1,1);
    CC_size_v = nan(length(el_bin)-1,1);
    DD_mean_v = nan(length(el_bin)-1,1);
    DD_std_v = nan(length(el_bin)-1,1);
    DD_size_v = nan(length(el_bin)-1,1);

    % For each elevation bin
    for i_el = 1:length(el_bin)-1
        % Find satellites at elevation within current interval
        ind = find(b>el_bin(i_el) & b<el_bin(i_el+1));
        % Find satellites at elevation within current interval excluding period from day 260 to 262
        indbis = find(bbis>el_bin(i_el) & bbis<el_bin(i_el+1));

%         figure(i_el); hold all
        AA_mean = NaN; AA_std = NaN; AA_size=0;
        BB_mean = NaN; BB_std = NaN; BB_size=0;
        CC_mean = NaN; CC_std = NaN; CC_size=0;
        DD_mean = NaN; DD_std = NaN; DD_size=0;
        if ~isempty(ind)
            AA_min = min(AA(ind)); AAmin = max(floor(10*AA_min)/10, -20);
            AA_max = max(AA(ind)); AAmax = min(floor(10*AA_max)/10, 20);
            AA_mean = mean(AA(ind));
            AA_std = std(AA(ind));
            AA_size = length(ind);

            CC_min = min(CC(indbis)); CCmin = max(floor(10*CC_min)/10, -20);
            CC_max = max(CC(indbis)); CCmax = min(floor(10*CC_max)/10, 20);
            CC_mean = mean(CC(indbis));
            CC_std = std(CC(indbis));
            CC_size = length(indbis);

            BB_min = min(BB(ind)); BBmin = max(floor(10*BB_min)/10, -20);
            BB_max = max(BB(ind)); BBmax = min(floor(10*BB_max)/10, 20);
            BB_mean = mean(BB(ind));
            BB_std = std(BB(ind));
            BB_size = length(ind);

            DD_min = min(DD(indbis)); DDmin = max(floor(10*DD_min)/10, -20);
            DD_max = max(DD(indbis)); DDmax = min(floor(10*DD_max)/10, 20);
            DD_mean = mean(DD(indbis));
            DD_std = std(DD(indbis));
            DD_size = length(indbis);
        end
        AA_mean_v(i_el) = AA_mean;
        AA_std_v(i_el) = AA_std;
        AA_size_v(i_el) = AA_size;
        BB_mean_v(i_el) = BB_mean;
        BB_std_v(i_el) = BB_std;
        BB_size_v(i_el) = BB_size;
        CC_mean_v(i_el) = CC_mean;
        CC_std_v(i_el) = CC_std;
        CC_size_v(i_el) = CC_size;
        DD_mean_v(i_el) = DD_mean;
        DD_std_v(i_el) = DD_std;
        DD_size_v(i_el) = DD_size;
        Result_MeanMat(ind_station,i_el) = DD_mean;
        Result_StdMat(ind_station,i_el) = DD_std;
        Result_SizeMat(ind_station,i_el) = DD_size;
    end
    figure(1);
%     subplot(431); hold all;
%     plot(el_bin(2:end),AA_mean_v)
%     subplot(432); hold all;
%     plot(el_bin(2:end),AA_std_v)
%     subplot(433); hold all;
%     plot(el_bin(2:end),AA_size_v)
%     subplot(434); hold all;
%     plot(el_bin(2:end),BB_mean_v)
%     subplot(435); hold all;
%     plot(el_bin(2:end),BB_std_v)
%     subplot(436); hold all;
%     plot(el_bin(2:end),BB_size_v)
%     subplot(437); hold all;
%     plot(el_bin(2:end),CC_mean_v)
%     subplot(438); hold all;
%     plot(el_bin(2:end),CC_std_v)
%     subplot(439); hold all;
%     plot(el_bin(2:end),CC_size_v)
%     subplot(1,3,1); hold all;
%     subplot(4,3,10); hold all;
    plot(el_bin(2:end),DD_mean_v)
    subplot(1,3,2); hold all;
%     subplot(4,3,11); hold all;
    plot(el_bin(2:end),DD_std_v)
    subplot(1,3,3); hold all;
%     subplot(4,3,12); hold all;
    plot(el_bin(2:end),DD_size_v)

    figure(2+SpaceGroup(ind_station));
    subplot(1,3,1); hold all;
    plot(el_bin(2:end),DD_mean_v)
    subplot(1,3,2); hold all;
    plot(el_bin(2:end),DD_std_v)
    subplot(1,3,3); hold all;
    plot(el_bin(2:end),DD_size_v)
end

save('Allstations_IONO_results_full2014.mat','Result_MeanMat','Result_StdMat','Result_SizeMat', 'el_bin');
figure(1);
subplot(1,3,1); hold all; title({'Mean of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,2); hold all; title({'StD of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,3); hold all; title('Number of samples for the stats')
legend(station_ECAC);

figure(2);
subplot(1,3,1); hold all; title({'Northern Stations'; 'Mean of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,2); hold all; title({'Northern Stations'; 'StD of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,3); hold all; title('Number of samples for the stats')
L = SpaceGroup==0; legend(station_ECAC(L,:));

figure(3);
subplot(1,3,1); hold all; title({'Northern ECAC center Stations'; 'Mean of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,2); hold all; title({'Northern ECAC center Stations'; 'StD of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,3); hold all; title('Number of samples for the stats')
L = SpaceGroup==1; legend(station_ECAC(L,:));

figure(4);
subplot(1,3,1); hold all; title({'ECAC center Stations'; 'Mean of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,2); hold all; title({'ECAC center Stations'; 'StD of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,3); hold all; title('Number of samples for the stats')
L = SpaceGroup==2; legend(station_ECAC(L,:));

figure(5);
subplot(1,3,1); hold all; title({'Southern ECAC center Stations'; 'Mean of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,2); hold all; title({'South West Stations'; 'StD of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,3); hold all; title('Number of samples for the stats')
L = SpaceGroup==3; legend(station_ECAC(L,:));

figure(6);
subplot(1,3,1); hold all; title({'Southern Stations'; 'Mean of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,2); hold all; title({'South East Stations'; 'StD of the Error'; '(Corr. from bias + Iono smooth.)'})
subplot(1,3,3); hold all; title('Number of samples for the stats')
L = SpaceGroup==4; legend(station_ECAC(L,:));
