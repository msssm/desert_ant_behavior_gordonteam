classdef Hashtable
    
    properties
        keys;
        data;
    end
    
    methods
        function hashTable = Hashtable
            hashTable.keys = {};
            hashTable.data = {};
        end
        
        function this = put(this,key,data)
            index = find(strcmp(this.keys,key));
            if isempty(index)
                if isempty(this.keys)
                    this.keys{1} = key;
                    this.data{1} = data;
                else
                    this.keys{end+1} = key;
                    this.data{end+1} = data;
                end
            else
                this.data{index} = data;
            end
        end
        
        function [angle length confidence] = get(this,key)
            index = find(strcmp(this.keys,key));
            if isempty(index)
                angle = [];
                length = [];
                confidence = [];
            else
                indexData = this.data{index};
                angle = indexData(1);
                length = indexData(2);
                confidence = indexData(3);
            end
        end
    end
end