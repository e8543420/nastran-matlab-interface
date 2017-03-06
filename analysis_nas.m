%本程序用于调用nastran进行计算并输出特定结果
function [output_resp,new_match]=analysis_nas(parm_input,output_type,name_bdf,name_unv,ref_vec,vec_match,auto_match)
% clear;
% output_type=1; %输出结果类型，1，模态 2, freq and modal vector
% modal_order=[1,2,3,4];
% parm_input=[1.04e11,9.2e9];
% name_bdf='modal-90.bdf';
%path_nastran='C:\MSC.Software\MSC_Nastran\20130\bin\nast20130.exe';  %nastran调用目录，换机器需要改
fid=fopen('./data/Nas_path.cfg','r');
tline=fgetl(fid);
path_nastran=tline;
fclose(fid);

new_match=[];% initializtion for output
output_resp=[];

fid=fopen('./parm.dat','r'); %读取修正参数信息
i=1;
while ~feof(fid)
    tline=fgetl(fid);
    tline_N=unicode2native(tline);
    if (str2num(native2unicode(tline_N(65:80)))~=0)
        x0(i)=str2num(native2unicode(tline_N(49:64)));
        parm_name{i}=native2unicode(tline_N(1:16));
        parm_id(i)=str2num(native2unicode(tline_N(33:48)));
        Upb(i)=str2num(native2unicode(tline_N(81:96)));
        Lob(i)=str2num(native2unicode(tline_N(97:112)));
        parm_line(i)=str2num(native2unicode(tline_N(113:128)));
        parm_pos(i)=str2num(native2unicode(tline_N(129:144)));
        if (~isempty(strfind(parm_name{i},'*')))
            parm_length(i)=16;
        else
            parm_length(i)=8;
        end
        i=i+1;
    end   
end

num_parm=i-1;
fclose(fid);

delete('./temp/*.*')
copyfile(strcat('./',name_bdf),'./temp/anaysis_temp.bdf');

for i=1:num_parm  %改写bdf
    fid=fopen('./temp/anaysis_temp.bdf','r');
    for j=1:parm_line(i)
        tline=fgetl(fid);
    end
    tparm_input{i}= sprintf(strcat('%',num2str(parm_length(i)+2),'.4g'), parm_input(i));
    tline(parm_pos(i):parm_pos(i)+parm_length(i)-1)=deal_e(tparm_input{i});
    position=ftell(fid);
    fclose(fid);
    
    fid2=fopen('./temp/anaysis_temp.bdf','r+');
    fseek(fid2,position-length(tline)-2,-1);
    fprintf(fid2,strcat(tline,'\r\n'));
    fclose(fid2);
end

oldPath=cd('.\temp'); %调用Nastran
[~,~]=system(strcat(path_nastran,' -j anaysis_temp -d ddd.db -w'));
cd(oldPath);

if output_type==1
    fid=fopen('./temp/anaysis_temp.f06','r');
    i=1;
    while ~feof(fid)
        tline=fgetl(fid);
        if((length(tline)>=77)&&(strcmp(tline(47:77),'R E A L   E I G E N V A L U E S')))
            tline=fgetl(fid);
            tline=fgetl(fid);
            tline=fgetl(fid);
            while(strcmp(tline(1:7),'       '))
                response_freq(i)=str2double(tline(61:79));
                i=i+1;
                tline=fgetl(fid);
            end
        end
    end
    fclose(fid);
    if i==1  %检查是否有结果
        output_resp=zeros(1,20);
        return
    end
    output_resp=response_freq;
    return
elseif output_type==2
    fid=fopen('./temp/anaysis_temp.f06','r');
    i=1;
    while ~feof(fid)
        tline=fgetl(fid);
        if((length(tline)>=77)&&(strcmp(tline(47:77),'R E A L   E I G E N V A L U E S')))
            tline=fgetl(fid);
            tline=fgetl(fid);
            tline=fgetl(fid);
            while(strcmp(tline(1:7),'       '))
                response_freq(i)=str2double(tline(61:79));
                i=i+1;
                tline=fgetl(fid);
            end
        end
    end
    fclose(fid);
    if i==1  %检查是否有结果
        output_resp=zeros(1,20);
        return
    end
    [MAC, MAC_diag, new_match]=mac_calc('./temp/anaysis_temp.bdf','./temp/anaysis_temp.f06',name_unv,ref_vec,vec_match,auto_match);
    output_resp=[response_freq,MAC_diag'];
    %plot_mac(MAC);%%%
    return
end










