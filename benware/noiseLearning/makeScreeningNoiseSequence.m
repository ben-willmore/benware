function makeScreeningSequence
global noiseTokens;
noiseTokens.screeningStimulus=noiseTokenSequence(noiseTokens.isi,noiseTokens.uniformSequence, noiseTokens.fs, noiseTokens.screeningNoise);