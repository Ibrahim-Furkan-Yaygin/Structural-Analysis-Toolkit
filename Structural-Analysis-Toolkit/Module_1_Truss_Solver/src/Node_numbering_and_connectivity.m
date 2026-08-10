function [truss_member_array, unique_nodes] = Node_numbering_and_connectivity(truss_member_array)

%NODE_NUMBERING_AND_CONNECTIVITY Generates unique nodes and element connectivity.
%   The function processes the truss member coordinates stored in a cell
%   array, identifies repeated nodes, assigns unique node numbers, and
%   determines the connectivity of each truss member.
%
%   Repeated nodes are merged using MATLAB's built-in UNIQUE function.
%   The resulting node numbers and connectivity information are stored in
%   the corresponding truss member data.
%
%   The function returns the numbered truss member array together with the
%   coordinates of the unique nodes.


% getting unique nodes out
all_member_nodes= [];

for i= 1:length(truss_member_array)
    member_nodes = truss_member_array{i};
    node_a = member_nodes(:,1)';
    node_b = member_nodes(:,2)';
    all_member_nodes = [all_member_nodes; node_a; node_b];
end

% along with the unique nodes, node numbering and node connectivity relations constructed
[unique_nodes, ~, node_map]= unique(all_member_nodes, 'rows'); 

% here the 3rd row of the coordinates turn into corresponding node number for that coordinate
node_map = node_map';
a=1;

for i= 1:length(truss_member_array)

    truss_member_array{i}(3,:) = node_map(a:a+1); 
    a=a+2;
end

end