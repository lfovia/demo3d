% Coherence score estimation
function[PsiScore] = DistanceComp(PristineFeatureSet,DistortedFeatureSet)
addpath(genpath('/home/sathya/DeMo3D/Codes/Toolbox'));
[l,f] = size(PristineFeatureSet);
for i =1:f
    temp= PristineFeatureSet(:,i);
    e_u_p= DistortedFeatureSet(:,i);
    FiSc(1,i)=(log(sum(sqrt((temp).*(e_u_p)))));
end
PsiScore = mean(FiSc(:));
end

