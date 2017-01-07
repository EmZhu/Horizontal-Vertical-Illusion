% WJM 20160710
% Emma's project on horizontal-vertical illusion
% Simulation of correlation between line and angle in a model in which the
% observer looks at a randomly oriented line in 3D space.
clear; close all;
set(0,'DefaultAxesFontSize',18)
set(0,'DefaultLineLineWidth',3)

load Girshick_Purves
Girshick = [Girshick; 180 + Girshick(1,1) Girshick(1,2)];
Purves = [Purves; 180 + Purves(1,1) Purves(1,2)];

% Azimuth angle theta uniform
% Polar angle phi: three cases ("prior")
% CASE 1: phi uniform
% CASE 2: phi = pi/2 (all lines in horizontal plane)
% CASE 3: phi from a mixture of Von Mises distributions

% Define bins
oribins = linspace(0,pi,62);
oricenters = oribins(1:end-1) + diff(oribins(1:2))/2;

lengthbins = linspace(0,1,62);
lengthcenters = lengthbins(1:end-1) + diff(lengthbins(1:2))/2;

% Number of Monte Carlo samples
nsamples = 2e7;

% Draw theta
theta = rand(nsamples, 1) * 2*pi;
st = sin(theta);
ct = cos(theta);

% Simulate for two alpha ranges
alpharangevec = [pi/4 pi/2];

% Draw phi and plot distribution
for prior = 1:3
    
    if prior == 2
        phi = pi/2;
        figure; plot([pi/2, pi/2], [0, 0.05], 'color', 'k', 'lineWidth', 4);
    else
        phivec = linspace(0,pi,181);
        if prior == 1
            phipdf = ones(1,length(phivec));
            phipdf = phipdf/sum(phipdf);
            phi = rand(nsamples,1)*pi;
            
        elseif prior == 3 % Mixture of uniform and delta
            
            pground = 0.45;
            ground = rand(nsamples,1)<pground;
            phi = rand(nsamples, 1)*pi;
            phi(ground) = pi/2;
            
        end
        phipdf = ones(1,length(phivec));
        phipdf = phipdf/sum(phipdf)*2;
%        phipdf(91) = 0.05;

        figure;
        plot(phivec, phipdf, 'color', 'k', 'lineWidth', 4);
    end
    set(gca,'xticklabel',[], 'yticklabel',[], 'xtick',0:pi/6:pi,'ytick',[],'tickdir','out','ticklength', 2*get(gca,'ticklength'))
    pbaspect([1 1 1]); axis([0 pi 0 0.05]); box off;
    
    sf = sin(phi);
    cf = cos(phi);
    
    meaninvprojlength   = NaN(length(alpharangevec),length(oribins)-1);
    projectedorihist    = NaN(length(alpharangevec),length(oribins)-1);
    projectedlengthhist = NaN(length(alpharangevec),length(lengthbins)-1);
    projectedjointhist  = NaN(length(alpharangevec),length(oribins),length(lengthbins)-1);
    
    for alpharangeind = 1:length(alpharangevec)
        alpharange = alpharangevec(alpharangeind);
        
        % Draw alpha
        alpha = rand(nsamples, 1) * alpharange*2-alpharange;
        sa = sin(alpha);
        ca = cos(alpha);
        
        % Crucial two lines: projected length and projected orientation
        projectedlength = sqrt(ct.^2 .* sf.^2 + (st .* sf .* sa + cf .* ca).^2);
        projectedori = acos(ct .* sf./projectedlength);
        
        % Orientation marginal
        temp = histc(projectedori, oribins)/nsamples;
        projectedorihist(alpharangeind,:) = temp(1:end-1);
        
        % Length marginal
        temp = histc(projectedlength, lengthbins)/nsamples;
        projectedlengthhist(alpharangeind,:) = temp(1:end-1);
        
        % Conditioned on orientation
        for i = 1:length(oribins)-1
            idx = find(projectedori > oribins(i) & projectedori < oribins(i+1));
            
            % Mean inverse length conditioned on orientation
            meaninvprojlength(alpharangeind, i) = mean(1./projectedlength(idx));
            
            % Joint distribution
            for j = 1:length(lengthbins)-1;
                idx = find(projectedori > oribins(i) & projectedori < oribins(i+1) & projectedlength > lengthbins(j) & projectedlength < lengthbins(j+1));
                projectedjointhist(alpharangeind, i, j) = length(idx);
            end
        end
    end
    
    col = [0 0.9 0; 0.8 0 1];
    
    %     % Joint distribution
    %     for alpharangeind = 1:length(alpharangevec)
    %         figure;
    %         imagesc(squeeze(projectedjointhist(alpharangeind,:,:)));
    %     end
    %
    % Orientation marginal
    figure;
    for alpharangeind = 1:length(alpharangevec)
        hold on;
        plot(oricenters, projectedorihist(alpharangeind,:)/sum(projectedorihist(alpharangeind,:)), 'color', col(alpharangeind,:), 'linewidth', 4);
    end
    axis([0 pi 0 0.05]);
    set(gca,'xticklabel',[], 'yticklabel',[], 'xtick',0:pi/6:pi,'ytick',[],'tickdir','out','ticklength', 2*get(gca,'ticklength'))
    pbaspect([1 1 1]); box off;
    
    % Relation between projected length and projected orientation
    figure;
    for alpharangeind = 1:length(alpharangevec)
        hold on;
        plot(oricenters, meaninvprojlength(alpharangeind, :), 'color', col(alpharangeind,:), 'linewidth', 4);
    end
    axis([0 pi 1 3]);
    set(gca,'xticklabel',[], 'yticklabel',[], 'xtick',0:pi/6:pi,'ytick',1:0.5:3,'tickdir','out','ticklength', 2*get(gca,'ticklength'))
    pbaspect([1 1 1]); box off;
    
    if prior == 3 % Mixture of Von Mises
        
        temp = interp1(Girshick(:,1)*pi/180, Girshick(:,2), oricenters);
        
        % Orientation marginal
        figure; hold on;
        plot(oricenters, projectedorihist(2,:), 'color', col(2,:), 'linewidth', 4);
        plot(oricenters, temp/sum(temp), 'k-','linewidth', 4);
        axis([0 pi 0 0.05]);
        set(gca,'xticklabel',[], 'yticklabel',[])
        set(gca,'xtick',0:pi/6:pi,'ytick',[])
        pbaspect([1 1 1])
        
        % Inverse mean projected length versus projected orientation
        [~,I] = sort(Purves(:,1));
        meaninvprojlengthnorm = meaninvprojlength(2, :)/meaninvprojlength(2, 1);
        
        figure; hold on;
        plot(oricenters, meaninvprojlengthnorm, 'color', col(2,:), 'linewidth', 4);
        plot(Purves(I,1)*pi/180, Purves(I,2), 'k-','linewidth', 4);
        axis([0 pi 1 1.35]);
        set(gca,'xtick',0:pi/6:pi,'ytick',1:0.05:1.35)
        set(gca,'xticklabel',[], 'yticklabel',[],'tickdir','out','ticklength', 2*get(gca,'ticklength'))
        pbaspect([1 1 1]); box off;
    end
end