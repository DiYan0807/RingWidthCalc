function [fitresult, gof] = Zringfit(Y)
%CREATEFIT(Y)
%  Create a fit.
%
%  Data for 'Zringfit' fit:
%      Y Output: Y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 23-Jul-2022 13:35:20 自动生成
%% initiate the start point
A1 = 0.7*(max(Y)-min(Y)); % peak of the first one
A2 = 0.3*(max(Y)-min(Y)); % peak of the first one
B1 = length(Y)/2; % position of the first one
B2 = length(Y)/2; % position of the first one
C1 = length(Y)/10; % sigma of the first one
C2 = length(Y); % sigma of the first one
C = min(Y); % plateau
%% Fit: 'Zringfit'.
[xData, yData] = prepareCurveData( [], Y );

% Set up fittype and options.
ft = fittype( 'a1*exp(-((x-b1)/sqrt(2)/c1)^2) + a2*exp(-((x-b2)/sqrt(2)/c2)^2)+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [A1 A2 B1 B2 C C1 C2];
opts.Lower = [0 0 0 0 0 0 0];
opts.Upper = [max(Y)-min(Y) max(Y)-min(Y) length(Y) length(Y) min(Y) length(Y)/2 length(Y)];
% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
% figure( 'Name', 'Zringfit' );
% h = plot( fitresult, xData, yData );
% legend( h, 'Y', 'Zringfit', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % Label axes
% ylabel( 'Y', 'Interpreter', 'none' );
% grid on


