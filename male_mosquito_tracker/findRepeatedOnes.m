function indices = findRepeatedOnes(binaryVector)
    % Initialize the indices array
    indices = [];
    
    % Ensure the input is a row vector
    binaryVector = binaryVector(:)';
    
    % Find the start and end indices of sequences of ones
    diffVector = diff([0, binaryVector, 0]);
    startIndices = find(diffVector == 1);
    endIndices = find(diffVector == -1) - 1;
    
    % Combine the start and end indices into a single matrix
    indices = [startIndices; endIndices]';
end