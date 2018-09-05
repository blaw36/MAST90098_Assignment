% This class was written by Brian Moore and shared on the Matlab Exchange
% https://au.mathworks.com/matlabcentral/fileexchange/45123-data-structures?focused=3805790&tab=function
% It has since been modified to support values being indexed by keys.

classdef MaxHeap < Heap
%--------------------------------------------------------------------------
% Class:        MaxHeap < Heap (& handle)
%               
% Constructor:  H = MaxHeap(n);
%               H = MaxHeap(n,x0,v0);
%               
% Properties:   (none)
%               
% Methods:                 H.Insert(key, value);
%               max      = H.ReturnMax();
%               max      = H.ExtractMax();
%               count    = H.Count();
%               capacity = H.Capacity();
%               bool     = H.IsEmpty();
%               bool     = H.IsFull();
%                          H.Clear();
%               
% Description:  This class implements a max-heap of numeric keys
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         January 16, 2014
%--------------------------------------------------------------------------

    %
    % Public methods
    %
    methods (Access = public)
        %
        % Constructor
        %
        function this = MaxHeap(varargin)
            %----------------------- Constructor --------------------------
            % Syntax:       H = MaxHeap(n);
            %               H = MaxHeap(n,x0,v0);
            %               
            % Inputs:       n is the maximum number of keys that H can hold
            %               
            %               x0 is a vector (of length <= n) of numeric keys
            %               to insert into the heap during initialization
            %               
            %               v0 is a vector of values of same length
            %               
            % Description:  Creates a max-heap with capacity n
            %--------------------------------------------------------------
            
            % Call base class constructor
            this = this@Heap(varargin{:});
            
            % Construct the max heap
            this.BuildMaxHeap();
        end
        
        %
        % Insert key
        %
        function Insert(this, key, value)
            %------------------------ InsertKey ---------------------------
            % Syntax:       H.Insert(key);
            %               
            % Inputs:       key is a number and value its value
            %               
            % Description:  Inserts key and value into H
            %--------------------------------------------------------------
            
            this.SetLength(this.k + 1);
            this.x(this.k) = -inf;
            this.v(this.k) = 0;
            this.PlaceKeyVal(this.k,key,value);
        end
        
        %
        % Return maximum element
        %
        function [key, val] = ReturnMax(this)
            %------------------------ ReturnMax ---------------------------
            % Syntax:       max = H.ReturnMax();
            %               
            % Outputs:      max is the maximum key in H
            %               
            % Description:  Returns the maximum key in H
            %--------------------------------------------------------------
            
            if (this.IsEmpty() == true)
                key = [];
                val = [];
            else
                key = this.x(1);
                val = this.v(1);
            end
        end
        
        %
        % Extract maximum element
        %
        function [key, val] = ExtractMax(this)
            %------------------------ ExtractMax --------------------------
            % Syntax:       [key, val] = H.ExtractMax();
            %               
            % Outputs:      key is the maximum key in H
            %               val its accompanying value
            %               
            % Description:  Returns the maximum key in H and extracts it
            %               from the heap
            %--------------------------------------------------------------
            
            key = this.x(1);
            val = this.v(1);
            
            this.SetLength(this.k - 1);
            this.x(1) = this.x(this.k + 1);
            this.v(1) = this.v(this.k + 1);
            this.MaxHeapify(1);
        end
    end
    
    %
    % Private methods
    %
    methods (Access = private)
        %
        % Increase key at index i
        %
        function PlaceKeyVal(this,i,key,value)
            if (i > this.k)
                % Index overflow error
                MaxHeap.IndexOverflowError();
            elseif (key < this.x(i))
                % Increase key error
                MaxHeap.IncreaseKeyError();
            end
            this.x(i) = key;
            this.v(i) = value;
            while ((i > 1) && (this.x(Heap.parent(i)) < this.x(i)))
                this.Swap(i,Heap.parent(i));
                i = Heap.parent(i);
            end
        end
        
        %
        % Build the max heap
        %
        function BuildMaxHeap(this)
            for i = floor(this.k / 2):-1:1
                this.MaxHeapify(i);
            end
        end
        
        %
        % Maintain the max heap property at a given node
        %
        function MaxHeapify(this,i,size)
            % Parse inputs
            if (nargin < 3)
                size = this.k;
            end
            
            ll = Heap.left(i);
            rr = Heap.right(i);
            if ((ll <= size) && (this.x(ll) > this.x(i)))
                largest = ll;
            else
                largest = i;
            end
            if ((rr <= size) && (this.x(rr) > this.x(largest)))
                largest = rr;
            end
            if (largest ~= i)
                this.Swap(i,largest);
                this.MaxHeapify(largest,size);
            end
        end
    end
    
    %
    % Private static methods
    %
    methods (Access = private, Static = true)
        %
        % Increase key error
        %
        function IncreaseKeyError()
            error('You can only increase keys in MaxHeap');
        end
        
        %
        % Index overflow error
        %
        function IndexOverflowError()
            error('MaxHeap index overflow');
        end
    end
end