function load_dataset(name)
    if name == "congress-LS"
        load_congress_LS();
    elseif name == "congress" || name == "mig"
        load_congress_mig_noise(name);
    elseif name == "BANDPASS"
        load_BANDPASS();
    else
        load_TU_dataset(name);
    end
end
