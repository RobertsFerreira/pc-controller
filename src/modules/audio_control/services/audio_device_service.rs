use crate::modules::audio_control::{
    models::device_sound::DeviceSound, types::audio_result::AudioResult,
};
use crate::modules::core::com::ComContext;

use windows::Win32::{
    Devices::FunctionDiscovery::PKEY_Device_FriendlyName,
    Media::Audio::{Endpoints::IAudioEndpointVolume, *},
    System::Com::{CoCreateInstance, StructuredStorage::PROPVARIANT, CLSCTX_ALL, STGM_READ},
};

/// Usa a API de dispositivos de áudio do Windows para enumerar
/// dispositivos de saída (speakers, headphones, etc.) que estão
/// atualmente ativos e conectados.
pub fn list_output_devices() -> AudioResult<Vec<DeviceSound>> {
    let _com_ctx = ComContext::new()?;
    unsafe {
        // Cria enumerador de dispositivos de áudio
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;

        // Enumera apenas dispositivos de saída (eRender) que estão ativos
        let device_collection: IMMDeviceCollection =
            device_enumerator.EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE)?;
        let device_count = device_collection.GetCount()?;

        if device_count == 0 {
            println!("no devices found");
            return Ok(Vec::new());
        }

        let mut devices: Vec<DeviceSound> = Vec::new();
        for index in 0..device_count {
            let device = match device_collection.Item(index) {
                Ok(device) => device,
                Err(error) => {
                    println!("Failed to get device at index {}: {:?}", index, error);
                    continue;
                }
            };

            let id_pointer = match device.GetId() {
                Ok(id_pointer) => id_pointer,
                Err(error) => {
                    println!("Failed to get device ID at index {}: {:?}", index, error);
                    continue;
                }
            };

            let id = match id_pointer.to_string() {
                Ok(id) => id,
                Err(error) => {
                    println!("Invalid device ID at index {}: {:?}", index, error);
                    continue;
                }
            };

            let property_store = match device.OpenPropertyStore(STGM_READ) {
                Ok(property_store) => property_store,
                Err(error) => {
                    println!(
                        "Failed to open property store for device {}: {:?}",
                        id, error
                    );
                    continue;
                }
            };

            let name_value: PROPVARIANT = match property_store.GetValue(&PKEY_Device_FriendlyName) {
                Ok(name_value) => name_value,
                Err(error) => {
                    println!("Failed to get friendly name for device {}: {:?}", id, error);
                    continue;
                }
            };

            let device_name = name_value.to_string();

            let device_sound = DeviceSound {
                id,
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
    let _com_ctx = ComContext::new()?;
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
