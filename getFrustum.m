function [frustum] = getFrustum(proj,modl)

clip = modl*proj;

%right plane           
frustum(1,:) = (-clip(:,1)+clip(:,4))';

%left plane          
frustum(2,:) = (clip(:,1)+clip(:,4))';

%bottom
frustum(3,:) = (clip(:,2)+clip(:,4))';

%top
frustum(4,:) = (-clip(:,2)+clip(:,4))';

%near
frustum(5,:) = (clip(:,3)+clip(:,4))';

%far
frustum(6,:) = (-clip(:,3)+clip(:,4))';

%normalize                     
frustum=frustum/norm(frustum);

end