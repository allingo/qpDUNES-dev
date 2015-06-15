% qpDUNES_dev QPDUNES_ERR_NEWTON_SYSTEM_NO_ASCENT_DIRECTION issue test.
run issue6_failed_qp

Nt = length(qp.C);
[Nx, Nz] = size(qp.C{1});

H = blkdiag(qp.H{:});
g = vertcat(qp.g{:});
Aeq = zeros(Nx * Nt, Nz * Nt + Nx);

% x_{k+1} = C_k * z_k + c_k
% => C_k * z_k - x_{k+1} = -c_k
for k = 1 : Nt
    Aeq((k - 1) * Nx + (1 : Nx), (k - 1) * Nz + (1 : Nz)) = -qp.C{k};
    Aeq((k - 1) * Nx + (1 : Nx), k * Nz + (1 : Nx)) = eye(Nx);
end

beq = vertcat(qp.c{:});
lb = vertcat(qp.zMin{:});
ub = vertcat(qp.zMax{:});

% % Solution that qpDUNES gives
% z_qpdunes = [ ...
%     8.88178000000000e-016,  -1.32482000000000e-012,  0.00000000000000e+000,  0.00000000000000e+000, -1.08420000000000e-019,  2.77556000000000e-017, ...
%     -2.92735000000000e-018, -1.11022000000000e-016, -1.01102000000000e-017,  5.80048000000000e-018, -6.72205000000000e-017,  2.33103000000000e-017, ...
%     -1.42302000000000e-018,  1.05384000000000e-016, -2.21584000000000e-018, -3.03577000000000e-017, -4.29214602496530e-003,  2.48858062841832e-003, ...
%     -4.04481308466967e-002,  1.65313054411648e-002, -6.11431685028896e-004, -7.98539301362502e-003, -9.61168801824657e-004,  1.09693911938649e-001, ...
%     -2.24190825303191e-005,  1.32350244607033e-005, -2.14863163558374e-004,  8.34470318014558e-005, -3.24844960628632e-006, -4.33634412669965e-005, ...
%     -5.10835100228388e-006,  5.74090389923200e-004, -4.43790301248280e-004,  2.58762031420925e-004, -4.22221654233489e-003,  1.66715427205821e-003, ...
%     -6.35329842514469e-005, -8.46207650681076e-004, -9.98979400912361e-005,  1.13352255969325e-002].';
% 
% Solve by quadprog
[z, fval] = quadprog(H, g, [], [], Aeq, beq, lb, ub);
disp(z);

% % Test if the two solutions are equal.
% err = max(abs(z_qpdunes(:) - z(:)))