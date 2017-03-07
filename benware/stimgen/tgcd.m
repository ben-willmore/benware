function y = tgcd(varargin)
%finds greatest common factor
%like 'gcd', but can cope with more inputs, either as a single vector, or
%as a list of arguments.

if nargin>1
    xs=[varargin{:}];
else
    xs=varargin{1};
end;

y=xs(1);
for ii=2:length(xs)
    y=gcd(y,xs(ii));
end;