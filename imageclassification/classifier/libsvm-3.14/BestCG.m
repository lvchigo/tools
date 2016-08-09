function [c g]= BestCG(trainD,gnd)
% BestCG.m
% automatic find the best c and g
% Usage:
%   [c g]= BestCG(trainD,gnd);
% Input:
%   trainD :trainData Matrix
%   gnd :train_label vector
% Output:
%   best c and g
%
% Author: gjtjx@163.com
% Date: 2012.4.24

%%
if nargin<2
   help BestCG;
   error('参数错误!');
end
[h w] = size(trainD);
if(h~=length(gnd))
    error('训练数据和标签size不一致!');
end
%%搜索的网格c,g：2^-10~2^10
bestcv = 0;
for log2c = -10:10,
  for log2g = -10:10,
    cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = get_cv_ac(trainD, gnd, cmd, 5);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    fprintf('(best c=%g, g=%g, rate=%g)n', bestc, bestg, bestcv*100);
  end
end

c = bestc;
g = bestg;
end