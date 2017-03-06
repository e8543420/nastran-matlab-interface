function [ output_text ] = expend_dotFormat( parameter_text )
%本函数用于扩展bdf中省略e的字符串
%注意，这个操作会使字符串扩张一位

parameter_text=strtrim(parameter_text);
minus_flag=0;
if (~isnan(str2double(parameter_text)))  %对于不需要处理的情况的判断
    output_text=parameter_text;
    return
end

if parameter_text(1)=='-'  %对于负数情况的处理
    minus_flag=1;
    parameter_text=parameter_text(2:end);
end

if (~isempty(strfind(parameter_text,'+')))
    output_text=strcat(parameter_text(1:strfind(parameter_text,'+')-1),'E',parameter_text(strfind(parameter_text,'+'):length(parameter_text)));
elseif (~isempty(strfind(parameter_text,'-')))
    output_text=strcat(parameter_text(1:strfind(parameter_text,'-')-1),'E',parameter_text(strfind(parameter_text,'-'):length(parameter_text)));
else
    output_text=parameter_text;
end

if minus_flag==1
    output_text=strcat('-',output_text);
end

return
