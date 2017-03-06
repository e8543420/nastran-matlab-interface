%This program is used for the reading of .bdf files
function [bdf]=bdf_read(bdf_name)
    %bdf_name='./modal_106_from_papaer.bdf';
    chan1=fopen(bdf_name,'r');
    %Parameter initialization
    bdf.GRID_num=0;
    while ~feof(chan1)
        line=fgetl(chan1);
        try
            if strcmpi(line(1:5),'GRID ')==1
                %Prototype for GRID card: bdf.GRID(1).Cord
                bdf.GRID_num=bdf.GRID_num+1;
                bdf.GRID_ID(bdf.GRID_num)=str2num(line(9:16));    
                bdf.GRID(bdf.GRID_num).Cord(1:3)=sscanf(line,'%*8c%*8c%*8c%8f%8f%8f');            
            elseif strcmpi(line(1:5),'GRID*')==1
                %To process *type cards
                bdf.GRID_num=bdf.GRID_num+1;
                bdf.GRID_ID(bdf.GRID_num)=str2num(line(9:32));
                bdf.GRID(bdf.GRID_num).Cord(1:2)=sscanf(line,'%*8c%*16c%*16c%16f%16f'); 
                line=fgetl(chan1);
                bdf.GRID(bdf.GRID_num).Cord(3)=sscanf(line,'%*8c%16f');
            end
        catch err
            if strcmpi(err.message,'Index exceeds matrix dimensions.')
                if length(line)<=5
                    continue
                else
                    error(err.message);
                end
            else
                error(err.message);
            end
        end
    end
    fclose(chan1);
    return
end