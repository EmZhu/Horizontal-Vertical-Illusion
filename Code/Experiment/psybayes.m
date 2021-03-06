function [xmin,tab,output] = psybayes(tab,method,vars,xi,yi,rt,plotflag) %xi-line length; yi-response
%PSYBAYES Adaptive Bayesian method for measuring threshold of psychometric function
%
% Author: Luigi Acerbi

if nargin < 1; tab = []; end
if nargin < 2; method = []; end
if nargin < 3; vars = []; end
if nargin < 4; xi = []; yi = []; rt = []; end
if nargin < 6 || isempty(plotflag); plotflag = 0; end

xmin = [];

% Default method is expected entropy minimization
if isempty(method); method = 'ent'; end

if isempty(vars)
    switch lower(method)
        case 'ent'; vars = [1 1 1];
        case 'var'; vars = [1 0 0];
        otherwise
            error('Unknown optimization method.');
    end
end

if numel(vars) ~= 3; error('VARS need to be a 3-element array for MU, SIGMA and LAMBDA.'); end

if isempty(tab) || ~isfield(tab,'post')  % First call, initialize everything
    tabinit = tab;
    tab = [];
    
    tab.ntrial = 0;     % Trial number
    tab.data = [];      % Record of data
    
    % Grid size
    nx = 61;
    nmu = 51;
    nsigma = 25;
    nlambda = 25;
    
    % Grid over parameters of psychometric function
    if isfield(tabinit,'range')
        tab.mu(:,1,1) = linspace(tabinit.range.mu(1),tabinit.range.mu(2),nmu);
        if isfield(tabinit.range,'sigma')
            tab.logsigma(1,:,1) = linspace(log(tabinit.range.sigma(1)), log(tabinit.range.sigma(2)), nsigma);
        elseif isfield(tabinit.range,'logsigma')
            tab.logsigma(1,:,1) = linspace(tabinit.range.logsigma(1), tabinit.range.logsigma(2), nsigma);
        else
            error('Cannot find a field in THETARANGE for SIGMA.');
        end
        if isfield(tabinit.range,'lambda')
            tab.lambda(1,1,:) = linspace(tabinit.range.lambda(1),tabinit.range.lambda(2),nlambda);
        else
            tab.lambda(1,1,:) = linspace(0, 0.2, nlambda);
        end
        tab.x(1,1,1,:) = linspace(tabinit.range.x(1),tabinit.range.x(2),nx);                
    else
        tab.mu(:,1,1) = linspace(2,4,nmu);
        tab.logsigma(1,:,1) = linspace(log(0.01), log(1), nsigma);
        tab.lambda(1,1,:) = linspace(0, 0.2, nlambda);
        tab.x(1,1,1,:) = linspace(2,4,nx);
    end
    
    if isfield(tabinit,'units')
        tab.units = tabinit.units;
    else
        tab.units.x = [];
        tab.units.mu = [];
        tab.units.sigma = []; 
        tab.units.lambda = []; 
    end
    
    % Very wide prior on mu with slight preference for the middle
    priormu = exp(-0.5.*((tab.mu-mean(tab.mu))/(tab.mu(end)-tab.mu(1))).^2);  
    
    % Flat prior on log sigma (Jeffrey's 1/sigma prior in sigma space)
    % You might want to put some weakly informative prior here
    %============================Weiji Approved===========================%  
    priorlogsigma = ones(size(tab.logsigma));
    %=====================================================================%
    
    
    % Beta(1,24) prior on lambda, with correction
    temp = tab.lambda(:)';
    temp = [0, temp + 0.5*[diff(temp),0]];
    a = 1; b = 24;
    priorlambda(1,1,:) = betainc(temp(2:end),a,b) - betainc(temp(1:end-1),a,b);
    
    priormu = priormu./sum(priormu);
    priorlogsigma = priorlogsigma./sum(priorlogsigma);
    priorlambda = priorlambda./sum(priorlambda);
    
    % Prior (posterior at iteration zero) over parameter vector theta
    tab.post = bsxfun(@times,bsxfun(@times,priormu,priorlogsigma),priorlambda);
%     tab.logpost = log(tab.post);
    
    % Define sigma in addition to log sigma
    tab.sigma = exp(tab.logsigma);
    
    tab.f = []; tab.mf = [];
    tab.logf = []; tab.log1mf = [];    
end

% Precompute psychometric function and its logarithm
if isempty(tab.f) || isempty(tab.mf) || isempty(tab.logf) || isempty(tab.log1mf)
    tab.f = psychofun(tab.x,tab.mu,tab.sigma,tab.lambda);
    tab.mf = 1 - tab.f;
    tab.logf = log(tab.f);
    tab.log1mf = log(1-tab.f);
end

% Update log posterior given the new data points XI, YI
if ~isempty(xi) && ~isempty(yi) && ~isempty(rt)   
    for i = 1:numel(xi)
        %=======================KEY RESPONSE IS 1&2=======================%  
        if yi(i) == 1 %
            like = psychofun(xi(i),tab.mu,tab.sigma,tab.lambda);
%             length(tab.mu)
%             length(tab.sigma)
%             length(tab.lambda)
%             size(like)
        else
            like = 1 - psychofun(xi(i),tab.mu,tab.sigma,tab.lambda); 
        end
        tab.post = tab.post.*like;
        %=================================================================%
    end
    tab.post = tab.post./sum(tab.post(:));
    
    tab.ntrial = tab.ntrial + numel(xi);
    tab.data = [tab.data; xi(:) yi(:) rt(:)];
end

% Compute mean of the posterior of mu
postmu = sum(sum(tab.post,2),3);
emu = sum(postmu.*tab.mu);

% Randomly remove half of the x
% if rand() < 0.5; xindex = tab.x < emu; else xindex = tab.x >= emu; end
xindex = true(size(tab.x));

% Compute best sampling point X that minimizes variance of MU
if nargin > 0
        
    xred = tab.x(xindex);
    
    % Compute posteriors at next step
    [post1,post0,r1] = nextposterior(tab.f(:,:,:,xindex),tab.post);
    
    
    % Marginalize over unrequested variables
    index = find(~vars);
    for iTheta = index
        post1 = sum(post1,iTheta);
        post0 = sum(post0,iTheta);
    end
    
    switch lower(method)
        case {'var','variance'}
            post1 = squeeze(post1);
            post0 = squeeze(post0);
            index = find(vars,1);
            switch index
                case 1; qq = tab.mu(:);
                case 2; qq = tab.logsigma(:);
                case 3; qq = tab.lambda(:);
            end
            mean1 = sum(bsxfun(@times,post1,qq),1);
            mean0 = sum(bsxfun(@times,post0,qq),1);
            var1 = sum(bsxfun(@times,post1,qq.^2),1) - mean1.^2;
            var0 = sum(bsxfun(@times,post0,qq.^2),1) - mean0.^2;
            target = r1(:).*var1(:) + (1-r1(:)).*var0(:);
                        
        case {'ent','entropy'}
            temp1 = -post1.*log(post1);
            temp0 = -post0.*log(post0);            
            temp1(~isfinite(temp1)) = 0;
            temp0(~isfinite(temp0)) = 0;
            H1 = temp1;     H0 = temp0;
            for iTheta = find(vars)
                H1 = sum(H1,iTheta);
                H0 = sum(H0,iTheta);
            end
            target = r1(:).*H1(:) + (1-r1(:)).*H0(:);
        otherwise
            error('Unknown method. Allowed methods are ''var'' and ''ent'' for, respectively, predicted variance and predicted entropy minimization.');
    end

    % Location X that minimizes target metric
    [~,index] = min(target);
    xmin = xred(index);
end

% Plot marginal posteriors and suggested next point X
if plotflag
    % Arrange figure panels in a 2 x 2 vignette
    rows = 2; cols = 2;
    % rows = 1; cols = 4;   % Alternative horizontal arrangement
    
    x = tab.x(:)';
    
    % Plot psychometric function
    subplot(rows,cols,1);
    
    psimean = zeros(1,numel(x));    psisd = zeros(1,numel(x));
    post = tab.post(:);
    for ix = 1:numel(x)
        f = psychofun(x(ix),tab.mu,tab.sigma,tab.lambda);
        psimean(ix) = sum(f(:).*post);
        psisd(ix) = sqrt(sum(f(:).^2.*post) - psimean(ix)^2);
    end    
    hold off;
    area(x, psimean + psisd, 'EdgeColor', 'none', 'FaceColor', 0.8*[1 1 1]);
    hold on;
    area(x, psimean - psisd, 'EdgeColor', 'none', 'FaceColor', [1 1 1]);
    plot(x, psimean,'k','LineWidth',1);
    plot([xmin,xmin],[0,1],':r', 'LineWidth', 2);
    if ~isempty(tab.data)
        scatter(tab.data(:,1),tab.data(:,2),20,'ko','MarkerFaceColor','r','MarkerEdgeColor','none');
    end
    box off; set(gca,'TickDir','out');    
    if ~isempty(tab.units.x); string = [' (' tab.units.x ')']; else string = []; end
    xlabel(['x' string]);
    ylabel('Pr(response = 1)');    
    axis([min(x) max(x), 0 1]);
    title(['Psychometric function (trial ' num2str(num2str(tab.ntrial)) ')']);
    
    % Plot posterior for mu
    subplot(rows,cols,3);
    y = sum(sum(tab.post,2),3);
    y = y/sum(y*diff(tab.mu(1:2)));    
    hold off;
    plot(tab.mu(:), y(:), 'k', 'LineWidth', 1);
    hold on;
    box off; set(gca,'TickDir','out');
    if ~isempty(tab.units.mu); string = [' (' tab.units.mu ')']; else string = []; end
    xlabel(['\mu' string]);
    ylabel('Posterior probability');
    % Compute SD of the posterior
    y = y/sum(y);
    ymean = sum(y.*tab.mu);
    ysd = sqrt(sum(y.*tab.mu.^2) - ymean^2);    
    if ~isempty(tab.units.mu); string = [' ' tab.units.mu]; else string = []; end
    title(['Posterior \mu = ' num2str(ymean,'%.2f') ' ? ' num2str(ysd,'%.2f') string])
    yl = get(gca,'Ylim'); axis([get(gca,'Xlim'),0,yl(2)]);
    plot([xmin,xmin],get(gca,'Ylim'),':r', 'LineWidth', 2);

    % Plot posterior for sigma
    subplot(rows,cols,2); hold off;
    y = sum(sum(tab.post,1),3);
    y = y/sum(y*diff(tab.sigma(1:2)));
    plot(tab.sigma(:), y(:), 'k', 'LineWidth', 1); hold on;
    box off; set(gca,'TickDir','out','XScale','log');
    %box off; set(gca,'TickDir','out','XScale','log','XTickLabel',{'0.1','1','10'});
    if ~isempty(tab.units.sigma); string = [' (' tab.units.sigma ')']; else string = []; end
    xlabel(['\sigma' string]);
    ylabel('Posterior probability');
    % title(['Marginal posterior distributions (trial ' num2str(tab.ntrial) ')']);
    % Compute SD of the posterior
    y = (y.*tab.sigma)/sum(y.*tab.sigma);
    ymean = sum(y.*tab.sigma);
    ysd = sqrt(sum(y.*tab.sigma.^2) - ymean^2);
    if ~isempty(tab.units.sigma); string = [' ' tab.units.sigma]; else string = []; end
    title(['Posterior \sigma = ' num2str(ymean,'%.2f') ' ? ' num2str(ysd,'%.2f') string]);
    yl = get(gca,'Ylim'); axis([tab.sigma(1),tab.sigma(end),0,yl(2)]);

    % Plot posterior for lambda
    subplot(rows,cols,4); hold off;
    y = sum(sum(tab.post,1),2);    
    y = y/sum(y*diff(tab.lambda(1:2)));
    plot(tab.lambda(:), y(:), 'k', 'LineWidth', 1); hold on;
    box off; set(gca,'TickDir','out');
    if ~isempty(tab.units.lambda); string = [' (' tabs.units.lambda ')']; else string = []; end
    xlabel(['\lambda' string]);
    ylabel('Posterior probability');    
    % Compute SD of the posterior
    y = y/sum(y);    
    ymean = sum(y.*tab.lambda);
    ysd = sqrt(sum(y.*tab.lambda.^2) - ymean^2);    
    if ~isempty(tab.units.lambda); string = [' ' tabs.units.lambda]; else string = []; end
    title(['Posterior \lambda = ' num2str(ymean,'%.2f') ' ? ' num2str(ysd,'%.2f') string])
    yl = get(gca,'Ylim'); axis([get(gca,'Xlim'),0,yl(2)]);

    
    set(gcf,'Color','w');
end

% Compute parameter estimates
if nargout > 2
    
    % Compute mean and variance of the estimate of MU
    postmu = sum(sum(tab.post,2),3);
    postmu = postmu./sum(postmu,1);
    emu = sum(postmu.*tab.mu,1);
    estd = sqrt(sum(postmu.*tab.mu.^2,1) - emu.^2);
    output.mu.mean = emu;
    output.mu.std = estd;
    
    % Compute mean and variance of the estimate of LOGSIGMA and SIGMA
    postlogsigma = sum(sum(tab.post,1),3);    
    postlogsigma = postlogsigma./sum(postlogsigma,2);    
    emu = sum(postlogsigma.*tab.logsigma,2);
    estd = sqrt(sum(postlogsigma.*tab.logsigma.^2,2) - emu.^2);
    output.logsigma.mean = emu;
    output.logsigma.std = estd;
    
    postsigma = postlogsigma./tab.sigma;
    postsigma = postsigma./sum(postsigma,2);    
    emu = sum(postsigma.*tab.sigma,2);
    estd = sqrt(sum(postsigma.*tab.sigma.^2,2) - emu.^2);
    output.sigma.mean = emu;
    output.sigma.std = estd;
    
    % Compute mean and variance of the estimate of LAMBDA
    postlambda = sum(sum(tab.post,1),2);
    postlambda = postlambda./sum(postlambda,3);    
    emu = sum(postlambda.*tab.lambda,3);
    estd = sqrt(sum(postlambda.*tab.lambda.^2,3) - emu.^2);
    output.lambda.mean = emu;
    output.lambda.std = estd;
    
end

% Only one argument assumes that this is the final call
if nargin < 2
    % Empty some memory
    tab.f = []; tab.mf = [];
    tab.logf = []; tab.log1mf = [];    
end

end


%--------------------------------------------------------------------------
function f = psychofun(x,mu,sigma,lambda)
%PSYCHOFUN Psychometric function

f = bsxfun(@plus, lambda/2, ...
    bsxfun(@times,1-lambda,0.5*(1+erf(bsxfun(@rdivide,bsxfun(@minus,x,mu),sqrt(2)*sigma)))));

end

%--------------------------------------------------------------------------
function [post1,post0,r1] = nextposterior(f,post)
%NEXTPOSTERIOR Compute posteriors on next trial depending on possible outcomes
%f-   ; post-   ;
%post1-   ; post0-   ; r1-    ;
    mf = 1-f;
    post1 = bsxfun(@times, post, f);
    r1 = sum(sum(sum(post1,1),2),3);
    post0 = bsxfun(@times, post, mf);
    post1 = bsxfun(@rdivide, post1, sum(sum(sum(post1,1),2),3));
    post0 = bsxfun(@rdivide, post0, sum(sum(sum(post0,1),2),3));    
end