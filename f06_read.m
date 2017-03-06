% This program is for the reading of f06 files
function [f06]=f06_read(f06_name)
    %f06_name='./modal_106_from_papaer.f06';
    chan1=fopen(f06_name,'r');
    %Parameter initialization
    f06.freq_num=0;
    f06.vec_num=1;
    f06.vec_point_num=0;
    while ~feof(chan1)
        line=fgetl(chan1);
        try
            if ((length(line)>=77)&&(strcmp(line(47:77),'R E A L   E I G E N V A L U E S')))
                %Prototype for modal frequency: f06.freq(1).freq
                line=fgetl(chan1);
                line=fgetl(chan1);
                line=fgetl(chan1);
                while(strcmp(line(1:7),'       '))
                    f06.freq_num=f06.freq_num+1;
                    f06.freq_ID(f06.freq_num)=str2double(line(1:10));
                    f06.freq(f06.freq_num).freq=str2double(line(61:79));
                    line=fgetl(chan1);
                end
            elseif ((length(line)>=80)&&(strcmp(line(42:80),'R E A L   E I G E N V E C T O R   N O .')))
                %Prototype for modal vectors: f06.vec(1).point(1).vec           
                if str2double(line(81:91))~=f06.vec_num
                    f06.vec_num=f06.vec_num+1;
                    f06.vec_point_num=0;
                end
                f06.vec_ID(f06.vec_num)=str2double(line(81:91));
                f06.vec(f06.vec_num).freq=str2double(line(19:32));
                line=fgetl(chan1);
                line=fgetl(chan1);
                line=fgetl(chan1);
                while(strcmp(line(1:7),'       '))
                    f06.vec_point_num=f06.vec_point_num+1;
                    f06.vec(f06.vec_num).point_ID(f06.vec_point_num)=str2double(line(1:14));
                    f06.vec(f06.vec_num).point(f06.vec_point_num).vec(1:6)=sscanf(line,'%*25c%15f%15f%15f%15f%15f%15f'); 
                    line=fgetl(chan1);
                end

            end

        catch err
            if strcmpi(err.message,'Index exceeds matrix dimensions.')
                if length(line)<=5
                    continue
                else
                    display(num2str(err.stack.line));
                    error(err.message);               
                end
            else
                display(num2str(err.stack.line));
                error(err.message);
            end
        end    
    end
    fclose(chan1);
    return
end