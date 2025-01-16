%analyze proportion of mosquitoes that took off for each stagemovement
%event for each video 
OutputTable=table();
Videos=unique(TakeOffData.Video);
for i = 1:length(Videos)
    VOI=Videos{i};
    subset_data = TakeOffData(strcmp(TakeOffData.Video, VOI), :);
    
    
    %calculate proportion having taken off for each stage movement event 
    SME=unique(subset_data.StageMoveFrame);
    
    for ii=1:length(SME)
        sub_subset_data=subset_data(subset_data.StageMoveFrame==SME(ii),:);
        TookOff=sub_subset_data.takeOffFrame<=sub_subset_data.EndFrame;
        PropTO=sum(TookOff)/length(TookOff);
        Light=sub_subset_data.Light{1};
        BSPropTO_median=bootStrapTable(strcmp(bootStrapTable.Light,Light),:).MedianPropTO{:};
        BSPropTO_mean=bootStrapTable(strcmp(bootStrapTable.Light,Light),:).MeanPropTO{:};
        BSPropTO_sd=bootStrapTable(strcmp(bootStrapTable.Light,Light),:).SDPropTO{:};
        %create miniTable for output
        miniTable=table();
        miniTable.Video={VOI};
        miniTable.Light=sub_subset_data.Light{1};
        miniTable.StageMoveFrame=sub_subset_data.StageMoveFrame(1);
        miniTable.StageMoveTime=sub_subset_data.StageMoveTime(1);
        miniTable.OnBackWall=height(sub_subset_data);
        miniTable.BSPropTO_median=BSPropTO_median;
        miniTable.BSPropTO_mean=BSPropTO_mean;
        miniTable.RawPropTO=PropTO;
        %grow table
       OutputTable=[OutputTable;miniTable];

    end
end
writetable(OutputTable,'PropTakeOff.xlsx')


        
        
