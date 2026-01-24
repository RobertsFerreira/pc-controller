use crate::modules::audio_control::{
    models::device_sound::DeviceSound, types::audio_result::AudioResult,
};
use crate::modules::core::com::ComContext;

use windows::Win32::{
    Devices::FunctionDiscovery::PKEY_Device_FriendlyName,
    Media::Audio::{Endpoints::IAudioEndpointVolume, *},
    System::Com::{CoCreateInstance, StructuredStorage::PROPVARIANT, CLSCTX_ALL, STGM_READ},
};

/// Lista todos os dispositivos de saída de áudio ativos
///
/// Usa a API de dispositivos de áudio do Windows para enumerar
/// dispositivos de saída (speakers, headphones, etc.) que estão
/// atualmente ativos e conectados.
pub fn list_output_devices() -> AudioResult<Vec<DeviceSound>> {
    ComContext::new()?;
    unsafe {
        // Cria enumerador de dispositivos de áudio
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;

        // Enumera apenas dispositivos de saída (eRender) que estão ativos
        let device_collection: IMMDeviceCollection =
            device_enumerator.EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE)?;
        let device_count = device_collection.GetCount()?;

        if device_count == 0 {
            print!("no devices found");
            return Ok(Vec::new());
        }

        let mut devices: Vec<DeviceSound> = Vec::new();
        for index in 0..device_count {
            let device: IMMDevice = device_collection.Item(index)?;
            let id = device.GetId()?.to_string();

            // Abre o repositório de propriedades para obter o nome do dispositivo
            let property_store = device.OpenPropertyStore(STGM_READ)?;
            let name_value: PROPVARIANT = property_store.GetValue(&PKEY_Device_FriendlyName)?;
            let device_name = name_value.to_string();

            let device_sound = DeviceSound {
                id: id.unwrap_or_default(),
                name: device_name.clone(),
                endpoint: device.clone(),
            };
            println!("Device {} pushed", device_sound.name);
            devices.push(device_sound);
        }
        Ok(devices)
    }
}

/// Obtém o volume atual do dispositivo de saída padrão
///
/// Retorna o volume como um valor de 0.0 a 100.0 (percentual).
pub fn get_actual_volume() -> AudioResult<f32> {
    ComContext::new()?;
    let result = unsafe {
        // Cria enumerador de dispositivos
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;

        // Obtém o dispositivo de saída padrão
        let device_default = device_enumerator.GetDefaultAudioEndpoint(eRender, eConsole)?;

        // Ativa o controle de volume do endpoint
        let volume_device_controller: IAudioEndpointVolume =
            device_default.Activate(CLSCTX_ALL, None)?;

        // Obtém volume como valor scalar (0.0 a 1.0)
        let current_volume = volume_device_controller.GetMasterVolumeLevelScalar()?;

        // Converte para percentual (0.0 a 100.0)
        let volume = if current_volume.is_nan() {
            0.0
        } else {
            current_volume * 100.0
        };
        println!("Volume: {}", volume);
        volume
    };
    Ok(result)
}
