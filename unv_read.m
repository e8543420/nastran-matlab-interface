%This program is used for the reading of .unv files
function [unv]=unv_read(unv_name)
    %unv_name='./test_example.unv';
    chan1=fopen(unv_name,'r');
    unv.node_num=0;
    unv.traceline_num=0;
    unv.vec_num=0;
    while ~feof(chan1)
        line=fgetl(chan1);
        try
            if (length(line)==6)&&(strcmpi(line(1:6),'    -1')==1)
                line=fgetl(chan1);
                if (length(line)==6)&&(strcmpi(line(1:6),'    15')==1) % 15 for nodes
                    line=fgetl(chan1);
                    while 1   %This is acturally a until loop
                        unv.node_num=unv.node_num+1;
                        unv.node_ID(unv.node_num)=sscanf(line,'%10i',1); 
                        unv.node(unv.node_num).Cord(1:3)=sscanf(line,'%*10c%*10c%*10c%*10c%13f%13f%13f',3);
                        line=fgetl(chan1);
                        if (length(line)==6)&&(strcmpi(line(1:6),'    -1')==1)%until part of the loop
                            break
                        end
                    end
                end

                if (length(line)==6)&&(strcmpi(line(1:6),'    82')==1) % 82 for tracelines
                    line=fgetl(chan1);
                    unv.traceline_num=+unv.traceline_num+1;
                    unv.traceline_ID(unv.traceline_num)=sscanf(line,'%10i',1);
                    unv.traceline(unv.traceline_num).node_num=sscanf(line,'%*10c%10i',1);
                    unv.traceline(unv.traceline_num).color=sscanf(line,'%*10c%*10c%10i',1);
                    line=fgetl(chan1);
                    unv.traceline(unv.traceline_num).name=sscanf(line,'%80c');
                    line=fgetl(chan1);
                    i=1;
                    while 1   %This is acturally a until loop
                        [line_int,count_i]=sscanf(line,'%10i');
                        unv.traceline(unv.traceline_num).node(i:i+count_i-1)=line_int;
                        i=i+count_i;
                        line=fgetl(chan1);
                        if (length(line)==6)&&(strcmpi(line(1:6),'    -1')==1)%until part of the loop
                            break
                        end
                    end
                end   

                if (length(line)==6)&&(strcmpi(line(1:6),'    55')==1) %55 for Data at nodes
                    line=fgetl(chan1);
                    line=fgetl(chan1);
                    line=fgetl(chan1);
                    line=fgetl(chan1);
                    line=fgetl(chan1);%skip the NONE lines
                    line=fgetl(chan1);
                    unv.vec_num=unv.vec_num+1;
                    parm=sscanf(line,'%10i');
                    unv.vec_ID(unv.vec_num)=unv.vec_num;
                    unv.vec(unv.vec_num).ModelType=parm(1);
                    unv.vec(unv.vec_num).AnalysisType=parm(2);
                    unv.vec(unv.vec_num).DataCharacteristic=parm(3);
                    unv.vec(unv.vec_num).SpecificDataType=parm(4);
                    unv.vec(unv.vec_num).DataType=parm(5);
                    unv.vec(unv.vec_num).NumOfDataPerNode=parm(6);
                    if unv.vec(unv.vec_num).AnalysisType==2 %For cases of Normal mode
                        line=fgetl(chan1);
                        parm=sscanf(line,'%10i');
                        unv.vec(unv.vec_num).LoadCaseNum=parm(3);
                        unv.vec(unv.vec_num).ModeNumber=parm(4);
                        line=fgetl(chan1);
                        parm=sscanf(line,'%13f');
                        unv.vec(unv.vec_num).Freq=parm(1);
                        unv.vec(unv.vec_num).ModalMass=parm(2);
                        unv.vec(unv.vec_num).VDamping=parm(3);
                        unv.vec(unv.vec_num).HDamping=parm(4);
                    end
                    line=fgetl(chan1);
                    unv.vec(unv.vec_num).num_point=0;
                    while 1   %This is acturally a until loop
                        unv.vec(unv.vec_num).num_point=unv.vec(unv.vec_num).num_point+1;
                        unv.vec(unv.vec_num).point_ID(unv.vec(unv.vec_num).num_point)=sscanf(line,'%10i',1); 
                        line=fgetl(chan1);
                        unv.vec(unv.vec_num).point(unv.vec(unv.vec_num).num_point).vec=sscanf(line,'%13f');
                        if unv.vec(unv.vec_num).NumOfDataPerNode==3
                            unv.vec(unv.vec_num).point(unv.vec(unv.vec_num).num_point).vec(4:6)=[0,0,0]; %Fill the rotational part of the data
                        end
                        line=fgetl(chan1);
                        if (length(line)==6)&&(strcmpi(line(1:6),'    -1')==1)%until part of the loop
                            break
                        end
                    end               
                end           
            end

        catch err
            if strcmpi(err.message,'Index exceeds matrix dimensions.')
                if length(line)<=6
                    line=fgetl(chan1);
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
    return;
end