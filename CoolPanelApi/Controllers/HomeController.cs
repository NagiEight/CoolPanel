using Microsoft.AspNetCore.Mvc;
using CoolPanelApi.Models;
using CoolPanelApi.Helpers;
namespace CoolPanelApi.Controllers;

[ApiController]
[Route("[controller]")]
public class HomeController : ControllerBase
{
    [HttpGet]
[HttpGet("system-usage")]
public async Task<IActionResult> GetSystemUsage()
{
    Console.WriteLine("Connection established from: ");
    try
    {
        // Await the result of the asynchronous method before returning it
        var systemUsage = await SystemUsageHelper.GetSystemUsageAsync();

        // Serialize only the result, which is safe for serialization
        return Ok(systemUsage);
    }
    catch (Exception ex)
    {
        // Log the error for debugging
        Console.WriteLine($"Error: {ex.Message}");

        // Return a 500 Internal Server Error with the message
        return StatusCode(500, "An error occurred while fetching system usage");
    }
}

}
